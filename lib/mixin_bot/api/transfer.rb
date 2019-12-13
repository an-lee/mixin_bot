# frozen_string_literal: true

module MixinBot
  class API
    module Transfer
      def create_transfer(pin, options, access_token: nil)
        asset_id = options[:asset_id]
        opponent_id = options[:opponent_id]
        amount = options[:amount]
        memo = options[:memo]
        trace_id = options[:trace_id] || SecureRandom.uuid

        path = '/transfers'
        payload = {
          asset_id: asset_id,
          opponent_id: opponent_id,
          pin: encrypt_pin(pin),
          amount: amount.to_s,
          trace_id: trace_id,
          memo: memo
        }

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def read_transfer(trace_id, access_token: nil)
        path = format('/transfers/trace/%<trace_id>s', trace_id: trace_id)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
    end
  end
end
