module MixinBot
  class API
    module Transfer
      def create_transfer(pin, options)
        options = options.with_indifferent_access

        asset_id = options.fetch('asset_id')
        opponent_id = options.fetch('opponent_id')
        amount = options.fetch('amount')
        memo = options.fetch('memo')
        trace_id = options.fetch('trace_id')
        trace_id ||= SecureRandom.uuid

        path = '/transfers'
        payload = {
          asset_id: asset_id,
          opponent_id: opponent_id,
          pin: pin,
          amount: amount,
          trace_id: trace_id,
          memo: memo
        }

        access_token ||= self.access_token('POST', path, payload.to_json)
        authorization = format('Bearer %s', access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def read_transfer(trace_id)
        path = format('/transfers/trace/%s', trace_id)
        access_token ||= self.access_token('GET', path, '')
        authorization = format('Bearer %s', access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
    end
  end
end
