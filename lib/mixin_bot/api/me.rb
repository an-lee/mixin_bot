# frozen_string_literal: true

module MixinBot
  class API
    module Me
      # https://developers.mixin.one/api/beta-mixin-message/read-profile/
      def me(access_token: nil)
        path = '/me'
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
      alias read_me me

      # https://developers.mixin.one/api/beta-mixin-message/update-profile/
      # avatar_base64:
      # String: Base64 of image, supports format png, jpeg and gif, base64 image size > 1024.
      def update_me(full_name:, avatar_base64: nil, access_token: nil)
        path = '/me'
        payload = {
          full_name: full_name,
          avatar_base64: avatar_base64
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # https://developers.mixin.one/api/beta-mixin-message/friends/
      def friends(access_token: nil)
        path = '/friends'
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
      alias read_friends friends

      def safe_me(**options)
        path = '/safe/me'
        access_token = options[:access_token] || access_token('GET', path)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
    end
  end
end
