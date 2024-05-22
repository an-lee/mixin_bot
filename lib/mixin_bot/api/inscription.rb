# frozen_string_literal: true

module MixinBot
  class API
    module Inscription
      def collection(hash, access_token: nil)
        path = "/inscriptions/collections/#{hash}"

        client.get path, access_token:
      end

      def collectible(hash, access_token: nil)
        path = "/inscriptions/items/#{hash}"

        client.get path, access_token:
      end
    end
  end
end
