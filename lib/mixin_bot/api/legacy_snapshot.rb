# frozen_string_literal: true

module MixinBot
  class API
    module LegacySnapshot
      def network_snapshots(**kwargs)
        path = '/network/snapshots'
        params = {
          limit: kwargs[:limit],
          offset: kwargs[:offset],
          asset: kwargs[:asset],
          order: kwargs[:order]
        }

        client.get path, **params, access_token: kwargs[:access_token]
      end
      alias read_network_snapshots network_snapshots

      def snapshots(**kwargs)
        path = '/snapshots'

        params = {
          limit: kwargs[:limit],
          offset: kwargs[:offset],
          asset: kwargs[:asset],
          opponent: kwargs[:opponent],
          order: kwargs[:order]
        }

        client.get path, **params, access_token: kwargs[:access_token]
      end
      alias read_snapshots snapshots

      def network_snapshot(snapshot_id, **kwargs)
        path = format('/network/snapshots/%<snapshot_id>s', snapshot_id:)

        client.get path, access_token: kwargs[:access_token]
      end
      alias read_network_snapshot network_snapshot
    end
  end
end
