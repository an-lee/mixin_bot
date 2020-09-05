# frozen_string_literal: true

module MixinBot
  class API
    module Snapshot
      def read_network_snapshots(options = {})
        path = format(
          '/network/snapshots?limit=%<limit>s&offset=%<offset>s&asset=%<asset>s&order=%<order>s',
          limit: options[:limit],
          offset: options[:offset],
          asset: options[:asset],
          order: options[:order]
        )

        access_token = options[:access_token] || access_token('GET', path)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def read_snapshots(options = {})
        path = format(
          '/snapshots?limit=%<limit>s&offset=%<offset>s&asset=%<asset>s',
          limit: options[:limit],
          offset: options[:offset],
          asset: options[:asset]
        )

        access_token = options[:access_token] || access_token('GET', path)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def read_network_snapshot(snapshot_id, options = {})
        path = format('/network/snapshots/%<snapshot_id>s', snapshot_id: snapshot_id)

        access_token = options[:access_token] || access_token('GET', path)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
    end
  end
end
