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
      def get_multisigs(limit: 100, offset: nil, access_token: nil)
        path = format('/multisigs?limit=%<limit>s&offset=%<offset>s', limit: limit, offset: offset)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def get_all_multisigs(utxos: [], offset: nil, access_token: nil)
        res = get_multisigs(limit: 100, offset: offset, access_token: access_token)
        utxos += res['data']

        if res['data'].length < 100
          utxos
        else
          get_all_multisigs(utxos: utxos, offset: utxos[-1]['created_at'], access_token: access_token)
        end
      end

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
        path = '/multisigs'
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
        path = '/multisigs'
        payload = {
          action: 'unlock',
          raw: raw
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # pay to the multisig address
      # used for create multisig payment code_id
      def create_multisig_payment(params)
        path = '/payments'
        payload = {
          asset_id: params[:asset_id],
          amount: params[:amount].to_s,
          trace_id: params[:trace_id] || SecureRandom.uuid,
          memo: params[:memo],
          opponent_multisig: {
            receivers: params[:receivers],
            threshold: params[:threshold]
          }
        }
        access_token = params[:access_token]
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
      def send_transaction_raw(raw, access_token: nil)
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
        s = s.length == 1 ? '0' + s : s
        raise 'NVALID THRESHOLD' if s.length > 2

        'fffe' + s
      end

      # FIXME
      # use a huge js method to implement for now
      def build_transaction(transaction)
        transaction = transaction.is_a?(String) ? transaction : transaction.to_json

        schmoozer.build_transaction transaction
      end

      def build_transaction_raw(options)
        payers         = options[:payers]
        receivers      = options[:receivers]
        asset_id       = options[:asset_id]
        asset_mixin_id = options[:asset_mixin_id]
        amount         = options[:amount]
        memo           = options[:memo]
        access_token   = options[:access_token]

        utxos = get_all_multisigs(access_token: access_token)
        utxos = utxos.filter(&->(utx) { utx['members'] == payers.sort && utx['asset_id'] == asset_id })
        input_amount = utxos.map(&->(utx) { utx['amount'].to_f }).sum
        amount = amount.to_f.round(8)

        raise format('not enough amount! %<input_amount>s < %<amount>s', input_amount: input_amount, amount: amount) if input_amount < amount

        inputs = utxos.map(&->(utx) { { hash: utx['transaction_hash'], index: utx['output_index'] } })

        outputs = []
        output0 = create_output(receivers: receivers, index: 0)['data']
        output0['amount'] = format('%<amount>.8f', amount: amount)
        output0['script'] = build_threshold_script(receivers.length)
        outputs << output0

        if input_amount > amount
          output1 = create_output(receivers: payers, index: 1)['data']
          output1['amount'] = format('%<amount>.8f', amount: input_amount - amount)
          output1['script'] = build_threshold_script(utxos[0]['threshold'].to_i)
          outputs << output1
        end

        extra = memo.to_s.each_byte.map { |b| b.to_s(16) }.join

        tx = {
          version: 1,
          asset: asset_mixin_id,
          inputs: inputs,
          outputs: outputs,
          extra: extra
        }

        build_transaction tx
      end
    end
  end
end
