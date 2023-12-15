# frozen_string_literal: true

module MixinBot
  class API
    module Transfer
      TRANSFER_ARGUMENTS = %i[asset_id opponent_id amount].freeze
      def create_transfer(pin, options = {})
        raise ArgumentError, "#{TRANSFER_ARGUMENTS.join(', ')} are needed for create transfer" unless TRANSFER_ARGUMENTS.all? { |param| options.keys.include? param }

        asset_id = options[:asset_id]
        opponent_id = options[:opponent_id]
        amount = format('%.8f', options[:amount].to_d.to_r).gsub(/\.?0+$/, '')
        trace_id = options[:trace_id] || SecureRandom.uuid
        memo = options[:memo] || ''

        payload = {
          asset_id: asset_id,
          opponent_id: opponent_id,
          amount: amount,
          trace_id: trace_id,
          memo: memo
        }

        encrypted_pin = options[:encrypted_pin]
        if pin.length > 6
          encrypted_pin ||= 
            encrypt_tip_pin pin, 'TIP:TRANSFER:CREATE:', asset_id, opponent_id, amount, trace_id, memo
          payload[:pin_base64] = encrypted_pin
        else
          encrypted_pin ||= encrypt_pin pin
          payload[:pin] = encrypted_pin
        end

        path = '/transfers'
        access_token = options[:access_token]
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def transfer(trace_id, access_token: nil)
        path = format('/transfers/trace/%<trace_id>s', trace_id: trace_id)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
      alias read_transfer transfer

      # kwargs:
      # {
      #  members: uuid | [ uuid ],
      #  threshold: integer / nil,
      #  asset_id: uuid,
      #  amount: string / float,
      #  trace_id: uuid / nil,
      #  request_id: uuid / nil,
      #  memo: string,
      # }
      def create_safe_transfer(**kwargs)
        asset_id = kwargs[:asset_id]
        raise ArgumentError, 'asset_id required' if asset_id.blank?

        amount = kwargs[:amount]&.to_d
        raise ArgumentError, 'amount required' if amount.blank?

        members = [kwargs[:members]].flatten.compact
        raise ArgumentError, 'members required' if members.blank?

        threshold = kwargs[:threshold] || members.length
        request_id = kwargs[:request_id] || kwargs[:trace_id] || SecureRandom.uuid
        memo = kwargs[:memo] || ''

        # step 1: select inputs
        outputs = safe_outputs(state: 'unspent', asset_id: asset_id, limit: 500)['data'].sort_by { |o| o['amount'].to_d }

        utxos = []
        outputs.each do |output|
          break if utxos.sum { |o| o['amount'].to_d } >= amount

          utxos.shift if utxos.size >= 255
          utxos << output
        end

        # step 2: build transaction
        tx = build_safe_transaction(
          utxos: utxos,
          receivers: [{
            members: members,
            threshold: threshold,
            amount: amount
          }],
          extra: memo
        )
        raw = MixinBot::Utils.encode_raw_transaction tx

        # step 3: verify transaction
        request = create_safe_transaction_request(request_id, raw)['data']

        # step 4: sign transaction
        signed_raw = sign_safe_transaction(
          raw: raw,
          utxos: utxos,
          request: request[0],
          spend_key: kwargs[:spend_key]
        )

        # step 5: submit transaction
        send_safe_transaction(
          request_id,
          signed_raw
        )
      end
    end
  end
end
