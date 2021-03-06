# frozen_string_literal: true

module MixinBot
  class API
    module Multisig
      # https://w3c.group/c/1574309272319630

      # {"data":[
      #   {
      #     "type":"multisig_utxo",
      #     "user_id":"514ae2ff-c24e-4379-a482-e2c0f798ebb1",
      #     "utxo_id":"94711ac9-5981-4fe3-8c0e-19622219ea72",
      #     "asset_id":"965e5c6e-434c-3fa9-b780-c50f43cd955c",
      #     "transaction_hash":"2e67f3e36ee4b3c13effcc8a9aaafeb8122cad98f72d9ccc04d65a5ada2aa39d",
      #     "output_index":0,
      #     "amount":"0.123456",
      #     "threshold":2,
      #     "members":[
      #       "514ae2ff-c24e-4379-a482-e2c0f798ebb1",
      #       "13ce6c86-307a-5187-98b0-76424cbc0fbf",
      #       "2b9df368-8e3e-46ce-ac57-e6111e8ff50e",
      #       "3cb87491-4fa0-4c2f-b387-262b63cbc412"
      #     ],
      #     "memo":"难道你是女生",
      #     "state":"unspent",
      #     "created_at":"2019-11-03T13:30:43.922655Z",
      #     "signed_by":"",
      #     "signed_tx":""
      #   }
      # ]}
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

      def create_output(receivers:, index:, access_token: nil)
        path = '/outputs'
        payload = {
          receivers: receivers,
          index: index
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # transfer from the multisig address
      # create a request for multi sign
      # for now, raw(RAW-TRANSACTION-HEX) can only be generated by Mixin SDK of Golang or Javascript
      def create_sign_multisig_request(raw, access_token: nil)
        path = '/multisigs/requests'
        payload = {
          action: 'sign',
          raw: raw
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # transfer from the multisig address
      # create a request for unlock a multi-sign
      def create_unlock_multisig_request(raw, access_token: nil)
        path = '/multisigs/requests'
        payload = {
          action: 'unlock',
          raw: raw
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
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
      def create_multisig_payment(**kwargs)
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
      RAW_TRANSACTION_ARGUMENTS = %i[senders receivers amount threshold asset_id].freeze
      def build_raw_transaction(**kwargs)
        raise ArgumentError, "#{RAW_TRANSACTION_ARGUMENTS.join(', ')} are needed for build raw transaction" unless RAW_TRANSACTION_ARGUMENTS.all? { |param| kwargs.keys.include? param }

        senders        = kwargs[:senders]
        receivers      = kwargs[:receivers]
        amount         = kwargs[:amount]
        threshold      = kwargs[:threshold]
        asset_id       = kwargs[:asset_id]
        utxos          = kwargs[:utxos]
        memo           = kwargs[:memo]
        access_token   = kwargs[:access_token]

        raise 'access_token required!' if access_token.nil? && !senders.include?(client_id)

        # default to use all(first 100) unspent utxo
        utxos ||= multisigs(
          members: senders,
          threshold: threshold,
          state: 'unspent',
          access_token: access_token
        ).filter(
          &lambda { |utxo|
            utxo['asset_id'] == kwargs[:asset_id]
          }
        )

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

        extra = Digest.hexencode memo.to_s.slice(0, 140)
        tx = {
          version: 1,
          asset: SHA3::Digest::SHA256.hexdigest(asset_id),
          inputs: inputs,
          outputs: outputs,
          extra: extra
        }

        build_transaction tx.to_json
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

      def build_outputs(outputs)
        res = []
        prototype = {
          'Type' => 0,
          'Amount' => nil,
          'Keys' => nil,
          'Script' => nil,
          'Mask' => nil
        }
        outputs.each do |output|
          struc = prototype.dup
          struc['Type'] = str_to_bin output['type']
          struc['Amount'] = str_to_bin output['amount']
          struc['Keys'] = output['keys'].map(&->(key) { str_to_bin(key) })
          struc['Script'] = str_to_bin output['script']
          struc['Mask'] = str_to_bin output['mask']
          res << struc
        end

        res
      end
    end
  end
end
