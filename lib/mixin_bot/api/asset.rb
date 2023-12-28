# frozen_string_literal: true

module MixinBot
  class API
    module Asset
      # https://developers.mixin.one/api/alpha-mixin-network/read-assets/
      def assets(access_token: nil)
        path = '/assets'
        client.get path, access_token:
      end

      # https://developers.mixin.one/api/alpha-mixin-network/read-asset/
      def asset(asset_id, access_token: nil)
        path = format('/assets/%<asset_id>s', asset_id:)
        client.get path, access_token:
      end

      # https://developers.mixin.one/document/wallet/api/ticker
      def ticker(asset_id, **kwargs)
        offset = kwargs[:offset]
        offset = DateTime.rfc3339(offset) if offset.is_a? String
        offset = offset.rfc3339 if offset.is_a?(DateTime) || offset.is_a?(Time)

        path = '/ticker'
        client.get path, asset_id:, offset:, access_token: kwargs[:access_token]
      end
    end
  end
end
