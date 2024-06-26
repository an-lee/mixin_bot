# frozen_string_literal: true

module MixinBot
  class API
    module Transfer
      # kwargs:
      # {
      #  members: uuid | [ uuid ],
      #  threshold: integer / nil,
      #  asset_id: uuid,
      #  amount: string / float,
      #  trace_id: uuid / nil,
      #  request_id: uuid / nil,
      #  memo: string,
      #  spend_key: string / nil,
      # }
      def create_safe_transfer(**kwargs)
        utxos = kwargs[:utxos]
        raise ArgumentError, 'utxos must be array' if utxos.present? && !utxos.is_a?(Array)

        asset_id =
          if utxos.present?
            utxos.first['asset_id']
          else
            kwargs[:asset_id]
          end

        raise ArgumentError, 'utxos or asset_id required' if utxos.blank? && asset_id.blank?

        amount = kwargs[:amount]&.to_d
        raise ArgumentError, 'amount required' if amount.blank?

        members = [kwargs[:members]].flatten.compact
        raise ArgumentError, 'members required' if members.blank?

        threshold = kwargs[:threshold] || members.length
        request_id = kwargs[:request_id] || kwargs[:trace_id] || SecureRandom.uuid
        memo = kwargs[:memo] || ''

        # step 1: select inputs
        utxos ||= build_utxos(asset_id:, amount:)

        # step 2: build transaction
        tx = build_safe_transaction(
          utxos:,
          receivers: [{
            members:,
            threshold:,
            amount:
          }],
          extra: memo
        )
        raw = MixinBot.utils.encode_raw_transaction tx

        # step 3: verify transaction
        request = create_safe_transaction_request(request_id, raw)['data']

        # step 4: sign transaction
        spend_key = MixinBot.utils.decode_key(kwargs[:spend_key]) || config.spend_key
        signed_raw = MixinBot.api.sign_safe_transaction(
          raw:,
          utxos:,
          request: request[0],
          spend_key:
        )

        # step 5: submit transaction
        send_safe_transaction(
          request_id,
          signed_raw
        )
      end
      alias create_transfer create_safe_transfer

      def build_utxos(asset_id:, amount:)
        outputs = safe_outputs(state: 'unspent', asset: asset_id, limit: 500)['data'].sort_by { |o| o['amount'].to_d }

        utxos = []
        outputs.each do |output|
          break if utxos.sum { |o| o['amount'].to_d } >= amount

          utxos.shift if utxos.size >= 256
          utxos << output
        end

        utxos
      end
    end
  end
end
