# frozen_string_literal: true

module MixinBot
  class API
    module Multisig
      def outputs(**kwargs)
        limit = kwargs[:limit] || 100
        offset = kwargs[:offset] || ''
        state = kwargs[:state] || ''
        members = kwargs[:members] || []
        threshold = kwargs[:threshold] || ''
        access_token = kwargs[:access_token]
        members = SHA3::Digest::SHA256.hexdigest(members&.sort&.join)

        path = format(
          '/multisigs/outputs?limit=%<limit>s&offset=%<offset>s&state=%<state>s&members=%<members>s&threshold=%<threshold>s',
          limit: limit,
          offset: offset,
          state: state,
          members: members,
          threshold: threshold
        )
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
      alias multisigs outputs
      alias multisig_outputs outputs

      def create_output(receivers:, index:, hint: nil, access_token: nil)
        path = '/outputs'
        payload = {
          receivers: receivers,
          index: index,
          hint: hint
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      MULTISIG_REQUEST_ACTIONS = %i[sign unlock].freeze
      def create_multisig_request(action, raw, access_token: nil)
        raise ArgumentError, "request action is limited in #{MULTISIG_REQUEST_ACTIONS.join(', ')}" unless MULTISIG_REQUEST_ACTIONS.include? action.to_sym

        path = '/multisigs/requests'
        payload = {
          action: action,
          raw: raw
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # transfer from the multisig address
      def create_sign_multisig_request(raw, access_token: nil)
        create_multisig_request 'sign', raw, access_token: access_token
      end

      # transfer from the multisig address
      # create a request for unlock a multi-sign
      def create_unlock_multisig_request(raw, access_token: nil)
        create_multisig_request 'unlock', raw, access_token: access_token
      end

      def sign_multisig_request(request_id, pin)
        path = format('/multisigs/requests/%<request_id>s/sign', request_id: request_id)
        payload = {
          pin: encrypt_pin(pin)
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def unlock_multisig_request(request_id, pin)
        path = format('/multisigs/requests/%<request_id>s/unlock', request_id: request_id)
        payload = {
          pin: encrypt_pin(pin)
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def cancel_multisig_request(request_id, pin)
        path = format('/multisigs/requests/%<request_id>s/cancel', request_id: request_id)
        payload = {
          pin: encrypt_pin(pin)
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # pay to the multisig address
      # used for create multisig payment code_id
      def create_payment(**kwargs)
        path = '/payments'
        payload = {
          asset_id: kwargs[:asset_id],
          amount: kwargs[:amount].to_s,
          trace_id: kwargs[:trace_id] || SecureRandom.uuid,
          memo: kwargs[:memo],
          opponent_multisig: {
            receivers: kwargs[:receivers],
            threshold: kwargs[:threshold]
          }
        }
        access_token = kwargs[:access_token]
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end
      alias create_multisig_payment create_payment

      def verify_multisig(code_id, access_token: nil)
        path = format('/codes/%<code_id>s', code_id: code_id)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      # send a signed transaction to main net
      def send_raw_transaction(raw, access_token: nil)
        path = '/external/proxy'
        payload = {
          method: 'sendrawtransaction',
          params: [raw]
        }

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def build_threshold_script(threshold)
        s = threshold.to_s(16)
        s = s.length == 1 ? "0#{s}" : s
        raise 'NVALID THRESHOLD' if s.length > 2

        "fffe#{s}"
      end

      # kwargs:
      # {
      #   senders: [ uuid ],
      #   receivers: [ uuid ],
      #   threshold: integer,
      #   asset_id: uuid,
      #   amount: string / float,
      #   memo: string,
      # }
      RAW_TRANSACTION_ARGUMENTS = %i[utxos senders receivers amount threshold].freeze
      def build_raw_transaction(**kwargs)
        raise ArgumentError, "#{RAW_TRANSACTION_ARGUMENTS.join(', ')} are needed for build raw transaction" unless RAW_TRANSACTION_ARGUMENTS.all? { |param| kwargs.keys.include? param }

        senders        = kwargs[:senders]
        receivers      = kwargs[:receivers]
        amount         = kwargs[:amount]
        threshold      = kwargs[:threshold]
        asset_id       = kwargs[:asset_id]
        asset_mixin_id = kwargs[:asset_mixin_id]
        utxos          = kwargs[:utxos]
        memo           = kwargs[:memo]
        extra          = kwargs[:extra]
        access_token   = kwargs[:access_token]

        raise 'access_token required!' if access_token.nil? && !senders.include?(client_id)

        amount = amount.to_f.round(8)
        input_amount = utxos.map(
          &lambda { |utxo|
            utxo['amount'].to_f
          }
        ).sum.round(8)

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

        outputs = []
        output0 = create_output(receivers: receivers, index: 0)['data']
        outputs << {
          'amount': format('%<amount>.8f', amount: amount),
          'script': build_threshold_script(receivers.length),
          'mask': output0['mask'],
          'keys': output0['keys']
        }

        if input_amount > amount
          output1 = create_output(receivers: senders, index: 1)['data']
          outputs << {
            'amount': format('%<amount>.8f', amount: input_amount - amount),
            'script': build_threshold_script(threshold.to_i),
            'mask': output1['mask'],
            'keys': output1['keys']
          }
        end

        extra = extra || Digest.hexencode(memo.to_s.slice(0, 140))
        asset = asset_mixin_id || SHA3::Digest::SHA256.hexdigest(asset_id)
        tx = {
          version: 2,
          asset: asset,
          inputs: inputs,
          outputs: outputs,
          extra: extra
        }

        tx.to_json
      end

      def str_to_bin(str)
        return if str.nil?

        str.scan(/../).map(&:hex).pack('c*')
      end

      def build_inputs(inputs)
        res = []
        prototype = {
          'Hash' => nil,
          'Index' => nil,
          'Genesis' => nil,
          'Deposit' => nil,
          'Mint' => nil
        }
        inputs.each do |input|
          struc = prototype.dup
          struc['Hash'] = str_to_bin input['hash']
          struc['Index'] = input['index']
          res << struc
        end

        res
      end

      def generate_trace_from_hash(hash, output_index = 0)
        MixinBot::Utils.generate_trace_from_hash hash, output_index
      end
    end
  end
end
