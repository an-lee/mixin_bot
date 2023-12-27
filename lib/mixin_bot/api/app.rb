# frozen_string_literal: true

module MixinBot
  class API
    module App
      def add_favorite_app(app_id, access_token: nil)
        path = format('/apps/%<id>s/favorite', id: app_id)

        client.post path, access_token:
      end

      def remove_favorite_app(app_id, access_token: nil)
        path = format('/apps/%<id>s/unfavorite', id: app_id)

        client.post path, access_token:
      end

      def favorite_apps(user_id, access_token: nil)
        path = format('/users/%<id>s/apps/favorite', id: user_id)

        client.get path, access_token:
      end
    end
  end
end
