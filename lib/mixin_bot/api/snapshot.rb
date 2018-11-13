module MixinBot
  class API
    module Snapshot
      def read_snapshots(options)
        options = options.with_indifferent_access
        limit = options.fetch('limit')
        offset = options.fetch('offset')
        asset = options.fetch('asset')
        order = options.fetch('order')

        order = 'snapshots'
        payload = {
          limit: limit,
          offset: offset,
          asset: asset,
          order: order
        }
        client.get(path, json: payload)
      end

      def read_snapshot(snapshot_id)
        path = format('snapshots/%s', snapshot_id)
        client.get(path)
      end
    end
  end
end
