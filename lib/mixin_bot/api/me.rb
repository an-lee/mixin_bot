# frozen_string_literal: true

module MixinBot
  class API
    module Me
      def me(access_token: nil)
        path = '/me'
        client.get path, access_token: access_token
      end

      # avatar_base64:
      #   String: Base64 of image, supports format png, jpeg and gif, base64 image size > 1024.
      def update_me(**kwargs)
        path = '/me'
        payload = {
          full_name: kwargs[:full_name],
          avatar_base64: kwargs[:avatar_base64],
          access_token: kwargs[:access_token]
        }
        client.post path, **payload
      end

      # https://developers.mixin.one/api/beta-mixin-message/friends/
      def friends(access_token: nil)
        path = '/friends'
        client.get path, access_token:
      end

      def safe_me(access_token: nil)
        path = '/safe/me'
        client.get path, access_token:
      end
    end
  end
end
