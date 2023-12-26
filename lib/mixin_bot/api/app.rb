# frozen_string_literal: true

module MixinBot
  class API
    module App
      def add_favorite_app(app_id, access_token: nil)
        path = format('/apps/%<id>s/favorite', id: app_id)

        access_token ||= access_token('POST', path)
        authorization = format('Bearer %<access_token>s', access_token:)
        client.post(path, headers: { Authorization: authorization })
      end

      def remove_favorite_app(app_id, access_token: nil)
        path = format('/apps/%<id>s/unfavorite', id: app_id)

        access_token ||= access_token('POST', path)
        authorization = format('Bearer %<access_token>s', access_token:)
        client.post(path, headers: { Authorization: authorization })
      end

      def favorite_apps(user_id, access_token: nil)
        path = format('/users/%<id>s/apps/favorite', id: user_id)

        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token:)
        client.get(path, headers: { Authorization: authorization })
      end
    end
  end
end
