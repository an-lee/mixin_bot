module MixinBot
  class API
    module Snapshot
      def read_snapshots(options)
        options = options.with_indifferent_access
        limit = options['limit']
        offset = options['offset']
        asset = options['asset']
        order = options['order']

        # path = 'network/snapshots'

        reqForAuthToken = "/network/snapshots"
        reqForAuthToken += "?limit=" + limit
        reqForAuthToken += "&offset=" + offset


        reqForAuthToken += "&asset=" + asset
        reqForAuthToken += "&order=" + order
        access_token = self.access_token('GET', reqForAuthToken, '')
        authorization = format('Bearer %s', access_token)
        client.get(reqForAuthToken, headers: { 'Authorization': authorization })
        # client.get(path, params: payload)
      end

      def read_snapshot(snapshot_id)
        path = format('network/snapshots/%s', snapshot_id)
        client.get(path)
      end
    end
  end
end
