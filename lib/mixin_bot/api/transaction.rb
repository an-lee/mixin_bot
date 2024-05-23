# frozen_string_literal: true

module MixinBot
  class API
    module Transaction
      SAFE_TX_VERSION = 0x05
      OUTPUT_TYPE_SCRIPT = 0x00
      OUTPUT_TYPE_WITHDRAW_SUBMIT = 0xa1
      XIN_ASSET_ID = 'c94ac88f-4671-3976-b60a-09064f1811e8'
      EXTRA_SIZE_STORAGE_CAPACITY = 1024 * 1024 * 4
      EXTRA_STORAGE_PRICE_STEP = 0.0001

      def create_safe_keys(*payload, access_token: nil)
        raise ArgumentError, 'payload should be an array' unless payload.is_a? Array
        raise ArgumentError, 'payload should not be empty' unless payload.size.positive?
        raise ArgumentError, 'invalid payload' unless payload.all?(&lambda { |param|
                                                                      param.key?(:receivers) && param.key?(:index)
                                                                    })

        payload.each do |param|
          param[:hint] ||= SecureRandom.uuid
        end

        path = '/safe/keys'

        client.post path, *payload, access_token:
      end
      alias create_ghost_keys create_safe_keys

      def generate_safe_keys(recipients)
        raise ArgumentError, 'recipients should be an array' unless recipients.is_a? Array

        ghost_keys = []
        uuid_recipients = []

        recipients.each_with_index do |recipient, index|
          next if recipient[:mix_address].blank?

          if recipient[:members].all?(&->(m) { m.start_with? MixinBot::Utils::Address::MAIN_ADDRESS_PREFIX })
            key = JOSE::JWA::Ed25519.keypair
            gk = {
              mask: key[0].unpack1('H*'),
              keys: []
            }
            recipient[:members].each do |member|
              payload = MixinBot.utils.parse_main_address member
              spend_key = payload[0...32]
              view_key = payload[-32..]

              ghost_public_key = MixinBot.utils.derive_ghost_public_key(key[1], view_key, spend_key, index)

              gk[:keys] << ghost_public_key.unpack1('H*')
            end

            ghost_keys[index] = gk.with_indifferent_access

          elsif recipient[:members].none?(&->(m) { m.start_with? MixinBot::Utils::Address::MAIN_ADDRESS_PREFIX })
            uuid_recipients.push(
              {
                receivers: recipient[:members],
                index:,
                hint: SecureRandom.uuid
              }.with_indifferent_access
            )
          end
        end

        if uuid_recipients.present?
          keys = create_safe_keys(*uuid_recipients)['data']
          keys.each_with_index do |key, index|
            ghost_keys[uuid_recipients[index][:index]] = key
          end
        end

        ghost_keys
      end

      # kwargs:
      # {
      #  utxos: [ utxo ],
      #  receivers: [ {
      #   members: [ uuid ],
      #   threshold: integer,
      #   amount: string,
      #  } ],
      #  ghosts: [ ghost ],
      #  extra: string,
      # }
      SAFE_RAW_TRANSACTION_ARGUMENTS = %i[utxos receivers].freeze
      def build_safe_transaction(**kwargs)
        raise ArgumentError, "#{SAFE_RAW_TRANSACTION_ARGUMENTS.join(', ')} are needed for build safe transaction" unless SAFE_RAW_TRANSACTION_ARGUMENTS.all? { |param| kwargs.keys.include? param }
        raise ArgumentError, 'receivers should be an array' unless kwargs[:receivers].is_a? Array
        raise ArgumentError, 'utxos should be an array' unless kwargs[:utxos].is_a? Array

        utxos = kwargs[:utxos].map(&:with_indifferent_access)
        receivers = kwargs[:receivers].map(&:with_indifferent_access)

        senders = utxos.map { |utxo| utxo['receivers'] }.uniq
        raise ArgumentError, 'utxos should have same senders' if senders.size > 1

        senders_threshold = utxos.map { |utxo| utxo['receivers_threshold'] }.uniq
        raise ArgumentError, 'utxos should have same senders_threshold' if senders_threshold.size > 1

        raise ArgumentError, 'utxos should not be empty' if utxos.empty?
        raise ArgumentError, 'utxos too many' if utxos.size > 256

        recipients = receivers.map do |receiver|
          MixinBot.utils.build_safe_recipient(
            members: receiver[:members],
            threshold: receiver[:threshold],
            amount: receiver[:amount]
          ).with_indifferent_access
        end

        inputs_sum = utxos.sum(&->(utxo) { utxo['amount'].to_d })
        outputs_sum = recipients.sum(&->(recipient) { recipient['amount'].to_d })
        change = inputs_sum - outputs_sum
        raise InsufficientBalanceError, "inputs sum #{inputs_sum} < outputs sum #{outputs_sum}" if change.negative?

        if change.positive?
          recipients << MixinBot.utils.build_safe_recipient(
            members: utxos.first['receivers'],
            threshold: utxos.first['receivers_threshold'],
            amount: change
          ).with_indifferent_access
        end
        raise ArgumentError, 'recipients too many' if recipients.size > 256

        asset = utxos[0]['asset']
        inputs = []
        utxos.each do |utxo|
          raise ArgumentError, 'utxo asset not match' unless utxo['asset'] == asset

          inputs << {
            hash: utxo['transaction_hash'],
            index: utxo['output_index']
          }
        end

        ghosts = generate_safe_keys(recipients)

        outputs = []
        recipients.each_with_index do |recipient, index|
          outputs << if recipient['destination']
                       {
                         type: OUTPUT_TYPE_WITHDRAW_SUBMIT,
                         amount: recipient['amount'],
                         withdrawal: {
                           address: recipient['destination'],
                           tag: recipient['tag'] || ''
                         }
                       }
                     else
                       {
                         type: OUTPUT_TYPE_SCRIPT,
                         amount: recipient['amount'],
                         keys: ghosts[index]['keys'],
                         mask: ghosts[index]['mask'],
                         script: build_threshold_script(recipient['threshold'])
                       }
                     end
        end

        {
          version: SAFE_TX_VERSION,
          asset:,
          inputs:,
          outputs:,
          extra: kwargs[:extra] || '',
          references: kwargs[:references] || []
        }
      end

      def create_safe_transaction_request(request_id, raw)
        path = '/safe/transaction/requests'
        payload = [{
          request_id:,
          raw:
        }]

        client.post path, *payload
      end

      def send_safe_transaction(request_id, raw)
        path = '/safe/transactions'
        payload = [{
          request_id:,
          raw:
        }]

        client.post path, *payload
      end

      def safe_transaction(request_id, access_token: nil)
        path = format('/safe/transactions/%<request_id>s', request_id:)

        client.get path, access_token:
      end

      SIGN_SAFE_TRANSACTION_ARGUMENTS = %i[raw utxos request spend_key].freeze
      def sign_safe_transaction(**kwargs)
        raise ArgumentError, "#{SIGN_SAFE_TRANSACTION_ARGUMENTS.join(', ')} are needed for sign safe transaction" unless SIGN_SAFE_TRANSACTION_ARGUMENTS.all? { |param| kwargs.keys.include? param }

        raw = kwargs[:raw]
        tx = MixinBot.utils.decode_raw_transaction raw
        utxos = kwargs[:utxos]
        request = kwargs[:request]
        spend_key = MixinBot.utils.decode_key(kwargs[:spend_key]) || config.spend_key
        spend_key = Digest::SHA512.digest spend_key[...32]

        msg = [raw].pack('H*')

        y_scalar = JOSE::JWA::FieldElement.new(
          JOSE::JWA::X25519.clamp_scalar(spend_key[...32]).x,
          JOSE::JWA::Edwards25519Point::L
        )

        tx[:signatures] = []
        tx[:inputs].each_with_index do |input, index|
          utxo = utxos[index]
          raise ArgumentError, 'utxo not match' unless input['hash'] == utxo['transaction_hash'] && input['index'] == utxo['output_index']

          view = [request['views'][index]].pack('H*')
          x_scalar = MixinBot.utils.scalar_from_bytes(view)

          t_scalar = x_scalar + y_scalar
          key = t_scalar.to_bytes(JOSE::JWA::Edwards25519Point::B)

          pub = MixinBot.utils.shared_public_key key
          key_index = utxo['keys'].index pub.unpack1('H*')
          raise ArgumentError, 'cannot find valid key' unless key_index.is_a? Integer

          signature = MixinBot.utils.sign(msg, key:)
          signature = signature.unpack1('H*')
          sig = {}
          sig[key_index] = signature
          tx[:signatures] << sig
        end

        MixinBot.utils.encode_raw_transaction tx
      end

      def build_object_transaction(extra, **)
        extra = extra.to_s
        raise ArgumentError, 'Extra too large' if extra.bytesize > EXTRA_SIZE_STORAGE_CAPACITY

        # calculate fee base on extra length
        amount = EXTRA_STORAGE_PRICE_STEP * ((extra.bytesize / 1024) + 1)

        # burning address
        receivers = [
          {
            members: [MixinBot.utils.burning_address],
            threshold: 64,
            amount:
          }
        ]

        # find XIN utxos
        utxos = build_utxos(asset_id: XIN_ASSET_ID, amount:)

        # build transaction
        build_safe_transaction utxos:, receivers:, extra:, **
      end

      INSCRIBE_TRANSACTION_ARGUMENTS = %i[content collection_hash].freeze
      def build_inscribe_transaction(**kwargs)
        raise ArgumentError, "#{INSCRIBE_TRANSACTION_ARGUMENTS.join(', ')} are needed for inscribe transaction" unless INSCRIBE_TRANSACTION_ARGUMENTS.all? { |param| kwargs.keys.include? param }

        receivers = kwargs[:receivers].presence || [config.app_id]
        receivers_threshold = kwargs[:receivers_threshold] || receivers.length
        recipient = MixinBot.utils.build_mix_address(receivers, receivers_threshold)

        content = kwargs[:content]
        collection_hash = kwargs[:collection_hash]

        data = {
          operation: 'inscribe',
          recipient:,
          content:
        }

        MixinBot.api.build_object_transaction data.to_json, references: [collection_hash]
      end
    end
  end
end
