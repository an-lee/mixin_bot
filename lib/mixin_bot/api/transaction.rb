# frozen_string_literal: true

module MixinBot
  class API
    module Transaction
      LEGACY_TX_VERSION = 0x04
      SAFE_TX_VERSION = 0x05
      OUTPUT_TYPE_SCRIPT = 0x00
      OUTPUT_TYPE_WITHDRAW_SUBMIT = 0xa1

      # @DEPRECATED
      # use safe transaction protocol instead
      # kwargs:
      # {
      #   senders: [ uuid ],
      #   senders_threshold: integer,
      #   receivers: [ uuid ],
      #   receivers_threshold: integer,
      #   asset_id: uuid,
      #   amount: string / float,
      #   memo: string,
      # }
      RAW_TRANSACTION_ARGUMENTS = %i[utxos senders senders_threshold receivers receivers_threshold amount].freeze
      def build_raw_transaction(**kwargs)
        raise ArgumentError, "#{RAW_TRANSACTION_ARGUMENTS.join(', ')} are needed for build raw transaction" unless RAW_TRANSACTION_ARGUMENTS.all? { |param| kwargs.keys.include? param }

        senders             = kwargs[:senders]
        senders_threshold   = kwargs[:senders_threshold]
        receivers           = kwargs[:receivers]
        receivers_threshold = kwargs[:receivers_threshold]
        amount              = kwargs[:amount]
        asset_id            = kwargs[:asset_id]
        asset_mixin_id      = kwargs[:asset_mixin_id]
        utxos               = kwargs[:utxos]
        memo                = kwargs[:memo]
        extra               = kwargs[:extra]
        access_token        = kwargs[:access_token]
        outputs             = kwargs[:outputs] || []
        hint                = kwargs[:hint]
        version             = kwargs[:version] || LEGACY_TX_VERSION

        raise 'access_token required!' if access_token.nil? && !senders.include?(client_id)

        amount = amount.to_d.round(8)
        input_amount = utxos.map(
          &lambda { |utxo|
            utxo['amount'].to_d
          }
        ).sum

        if input_amount < amount
          raise format(
            'not enough amount! %<input_amount>s < %<amount>s',
            input_amount: input_amount,
            amount: amount
          )
        end

        inputs = utxos.map(
          &lambda { |utx|
            {
              'hash' => utx['transaction_hash'],
              'index' => utx['output_index']
            }
          }
        )

        if outputs.empty?
          receivers_threshold = 1 if receivers.size == 1
          output0 = build_output(
            receivers: receivers,
            index: 0,
            amount: amount,
            threshold: receivers_threshold,
            hint: hint
          )
          outputs.push output0

          if input_amount > amount
            output1 = build_output(
              receivers: senders,
              index: 1,
              amount: input_amount - amount,
              threshold: senders_threshold,
              hint: hint
            )
            outputs.push output1
          end
        end

        # extra ||= Digest.hexencode(memo.to_s.slice(0, 140))
        asset = asset_mixin_id || SHA3::Digest::SHA256.hexdigest(asset_id)
        tx = {
          version: version,
          asset: asset,
          inputs: inputs,
          outputs: outputs,
          extra: extra
        }
      end

      # @DEPRECATED
      # use safe transaction protocol instead
      MULTISIG_TRANSACTION_ARGUMENTS = %i[asset_id receivers threshold amount].freeze
      def create_multisig_transaction(pin, options = {})
        raise ArgumentError, "#{MULTISIG_TRANSACTION_ARGUMENTS.join(', ')} are needed for create multisig transaction" unless MULTISIG_TRANSACTION_ARGUMENTS.all? { |param| options.keys.include? param }

        asset_id = options[:asset_id]
        receivers = options[:receivers]
        threshold = options[:threshold]
        amount = format('%.8f', options[:amount].to_d.to_r),
        memo = options[:memo]
        trace_id = options[:trace_id] || SecureRandom.uuid

        path = '/transactions'
        payload = {
          asset_id: asset_id,
          opponent_multisig: {
            receivers: receivers,
            threshold: threshold
          },
          amount: amount,
          trace_id: trace_id,
          memo: memo
        }

        if pin.length > 6
          payload[:pin_base64] = encrypt_tip_pin(pin, 'TIP:TRANSACTION:CREATE:', asset_id, receivers.join, threshold, amount, trace_id, memo)
        else
          payload[:pin] = encrypt_pin(pin)
        end

        access_token = options[:access_token]
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # @DEPRECATED
      # use safe transaction protocol instead
      MAINNET_TRANSACTION_ARGUMENTS = %i[asset_id opponent_key amount].freeze
      def create_mainnet_transaction(pin, options = {})
        raise ArgumentError, "#{MAINNET_TRANSACTION_ARGUMENTS.join(', ')} are needed for create main net transactions" unless MAINNET_TRANSACTION_ARGUMENTS.all? { |param| options.keys.include? param }

        asset_id = options[:asset_id]
        opponent_key = options[:opponent_key]
        amount = format('%.8f', options[:amount].to_d.to_r),
        memo = options[:memo]
        trace_id = options[:trace_id] || SecureRandom.uuid
        encrypted_pin = options[:encrypted_pin] || encrypt_pin(pin)

        path = '/transactions'
        payload = {
          asset_id: asset_id,
          opponent_key: opponent_key,
          amount: amount,
          trace_id: trace_id,
          memo: memo
        }

        if pin.length > 6
          payload[:pin_base64] = encrypt_tip_pin(pin, 'TIP:TRANSACTION:CREATE:', asset_id, opponent_key, amount, trace_id, memo)
        else
          payload[:pin] = encrypt_pin(pin)
        end

        access_token = options[:access_token]
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # @DEPRECATED
      # use safe transaction protocol instead
      def transactions(**options)
        path = format(
          '/external/transactions?limit=%<limit>s&offset=%<offset>s&asset=%<asset>s&destination=%<destination>s&tag=%<tag>s',
          limit: options[:limit],
          offset: options[:offset],
          asset: options[:asset],
          destination: options[:destination],
          tag: options[:tag]
        )

        client.get path
      end

      #########################
      # Safe Network Protocol #
      # #######################
      
      # ghost keys
      def create_safe_keys(*payload, access_token: nil)
        raise ArgumentError, 'payload should be an array' unless payload.is_a? Array
        raise ArgumentError, 'payload should not be empty' unless payload.size > 0
        raise ArgumentError, 'invalid payload' unless payload.all?(&->(param) {
          param.has_key?(:receivers) && param.has_key?(:index) })

        payload.each do |param|
          param[:hint] ||= SecureRandom.uuid
        end

        path = '/safe/keys'
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
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

        raise ArgumentError, 'utxos should not be empty' if utxos.size == 0
        raise ArgumentError, 'utxos too many' if utxos.size > 256

        recipients = receivers.map do |receiver|
          build_safe_recipient(
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
          recipients << build_safe_recipient(
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
            index: utxo['output_index'],
          }
        end

        ghost_payload = recipients.map.with_index do |r, index|  
          {
            receivers: r[:members],
            index: index,
            hint: SecureRandom.uuid
          }
        end 
        ghosts = create_safe_keys(*ghost_payload)['data']

        outputs = []
        recipients.each_with_index do |recipient, index|
          if recipient['destination']
            outputs << {
              type: OUTPUT_TYPE_WITHDRAW_SUBMIT,
              amount: recipient['amount'],
              withdrawal: {
                address: recipient['destination'],
                tag: recipient['tag'] || '',
              }
            }
          else
            outputs << {
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
        }
      end

      def create_safe_transaction_request(request_id, raw)
        path = '/safe/transaction/requests'
        payload = [{
          request_id: request_id,
          raw: raw
        }]

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def send_safe_transaction(request_id, raw)
        path = '/safe/transactions'
        payload = [{
          request_id: request_id,
          raw: raw
        }]

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def safe_transaction(request_id)
        path = format('/safe/transactions/%<request_id>s', request_id: request_id)

        access_token = access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def sign_safe_transaction(**kwargs)
        raw = kwargs[:raw]
        tx = MixinBot::Utils.decode_raw_transaction raw
        utxos = kwargs[:utxos]
        request = kwargs[:request]

        msg = [raw].pack('H*')
        spend_key = kwargs[:spend_key] || private_key
        spend_key = Digest::SHA512.digest spend_key[...32]

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

          pub = MixinBot::Utils.generate_public_key key
          key_index = utxo['keys'].index pub.unpack1('H*')
          raise ArgumentError, 'cannot find valid key' unless key_index.is_a? Integer

          signature = MixinBot::Utils.sign msg, key: key
          signature = signature.unpack1('H*')
          sig = {}
          sig[key_index] = signature
          tx[:signatures] << sig
        end

        MixinBot::Utils.encode_raw_transaction tx
      end
    end
  end
end
