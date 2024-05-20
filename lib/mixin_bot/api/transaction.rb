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

      # ghost keys
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
        raise InsufficientBalanceError, "inputs sum: #{inputs_sum}" if change.negative?

        if change.positive?
          recipients << MixinBot.utils.build_safe_recipient(
            members: utxos[0]['receivers'],
            threshold: utxos[0]['receivers_threshold'],
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

        ghost_payload = recipients.map.with_index do |r, index|
          {
            receivers: r[:members],
            index:,
            hint: SecureRandom.uuid
          }
        end
        ghosts = create_safe_keys(*ghost_payload)['data']

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
          extra: kwargs[:extra] || ''
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

        y_point = JOSE::JWA::FieldElement.new(
          JOSE::JWA::X25519.clamp_scalar(spend_key[...32]).x,
          JOSE::JWA::Edwards25519Point::L
        )

        tx[:signatures] = []
        tx[:inputs].each_with_index do |input, index|
          utxo = utxos[index]
          raise ArgumentError, 'utxo not match' unless input['hash'] == utxo['transaction_hash'] && input['index'] == utxo['output_index']

          view = [request['views'][index]].pack('H*')
          x_point = JOSE::JWA::FieldElement.new(
            # https://github.com/potatosalad/ruby-jose/blob/e1be589b889f1e59ac233a5d19a3fa13f1e4b8a0/lib/jose/jwa/x25519.rb#L122C14-L122C48
            OpenSSL::BN.new(view.reverse, 2),
            JOSE::JWA::Edwards25519Point::L
          )

          t_point = x_point + y_point
          key = t_point.to_bytes(JOSE::JWA::Edwards25519Point::B)

          pub = MixinBot.utils.generate_public_key key
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

      def build_object_transaction(extra)
        raise 'Extra to large' if extra.bytesize > EXTRA_SIZE_STORAGE_CAPACITY

        # calculate fee base on extra length
        amount = EXTRA_STORAGE_PRICE_STEP * ((extra.bytesize / 1024) + 1)

        receivers = [
          {
            members: [MixinBot.utils.burning_address],
            threshold: 64,
            amount:
          }
        ]

        outputs = MixinBot.api.safe_outputs(state: 'unspent', asset: XIN_ASSET_ID)['data'].sort_by { |o| o['amount'].to_d }

        utxos = []
        outputs.each do |output|
          break if utxos.sum { |o| o['amount'].to_d } >= amount

          utxos.shift if utxos.size >= 256
          utxos << output
        end

        build_safe_transaction utxos:, receivers:, extra:
      end
    end
  end
end
