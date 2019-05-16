module MixinBot
  class API
    module Snapshot
      def read_snapshots(options)
        options = options.with_indifferent_access
        limit = options['limit']
        offset = options['offset']
        asset = options['asset']
        order = options['order']

        path = 'network/snapshots'
        payload = {
          limit: limit,
          offset: offset,
          asset: asset,
          order: order
        }
        client.get(path, params: payload)
      end

      def read_snapshot(snapshot_id)
        path = format('network/snapshots/%s', snapshot_id)
        client.get(path)
      end
    end
  end
end
