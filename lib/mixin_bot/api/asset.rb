# frozen_string_literal: true

module MixinBot
  class API
    module Asset
      # https://developers.mixin.one/api/alpha-mixin-network/read-assets/
      def assets(access_token: nil)
        path = '/assets'
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
      alias read_assets assets

      # https://developers.mixin.one/api/alpha-mixin-network/read-asset/
      def asset(asset_id, access_token: nil)
        path = format('/assets/%<asset_id>s', asset_id: asset_id)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
      alias read_asset asset

      # https://developers.mixin.one/document/wallet/api/ticker
      def ticker(asset_id, offset, access_token: nil)
        offset = DateTime.rfc3339 offset if offset.is_a? String
        offset = offset.rfc3339 if offset.is_a?(DateTime) || offset.is_a?(Time)
        path = format('/ticker?asset=%<asset_id>s&offset=%<offset>s', asset_id: asset_id, offset: offset)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
      alias read_ticker ticker
    end
  end
end
