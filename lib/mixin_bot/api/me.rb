# frozen_string_literal: true

module MixinBot
  class API
    ##
    # API methods for bot profile management.
    #
    # Provides methods to:
    # - Retrieve bot profile information
    # - Update bot profile (name, avatar)
    # - List friends
    # - Access Safe API profile
    #
    module Me
      ##
      # Retrieves the bot's profile information.
      #
      # Returns detailed information about the bot including:
      # - user_id
      # - full_name
      # - avatar_url
      # - identity_number
      # - phone
      # - biography
      # - created_at
      #
      # @param access_token [String, nil] optional access token for authentication
      # @return [Hash] the bot profile
      #
      # @example
      #   profile = api.me
      #   puts profile['full_name']
      #   puts profile['identity_number']
      #
      # @see https://developers.mixin.one/docs/api/users/me
      #
      def me(access_token: nil)
        path = '/me'
        client.get path, access_token:
      end

      ##
      # Updates the bot's profile.
      #
      # Allows updating:
      # - full_name: the bot's display name
      # - avatar_base64: Base64-encoded avatar image (PNG, JPEG, or GIF, size > 1024 bytes)
      #
      # @param kwargs [Hash] update options
      # @option kwargs [String] :full_name the new name for the bot
      # @option kwargs [String] :avatar_base64 Base64-encoded image data
      # @option kwargs [String] :access_token optional access token
      # @return [Hash] the updated profile
      #
      # @example
      #   api.update_me(full_name: 'My Awesome Bot')
      #   api.update_me(avatar_base64: Base64.strict_encode64(File.read('avatar.png')))
      #
      def update_me(**kwargs)
        path = '/me'
        payload = {
          full_name: kwargs[:full_name],
          avatar_base64: kwargs[:avatar_base64],
          access_token: kwargs[:access_token]
        }
        client.post path, **payload
      end

      ##
      # Retrieves the bot's friend list.
      #
      # Returns an array of users who have interacted with the bot
      # and are in the bot's contact list.
      #
      # @param access_token [String, nil] optional access token
      # @return [Array<Hash>] array of user profiles
      #
      # @example
      #   friends = api.friends
      #   friends.each do |friend|
      #     puts "#{friend['full_name']} (#{friend['user_id']})"
      #   end
      #
      # @see https://developers.mixin.one/docs/api/users/friends
      #
      def friends(access_token: nil)
        path = '/friends'
        client.get path, access_token:
      end

      ##
      # Retrieves the bot's Safe API profile.
      #
      # Returns Safe API-specific profile information including:
      # - Safe wallet address
      # - TIP signing key
      # - Safe network status
      #
      # @param access_token [String, nil] optional access token
      # @return [Hash] the Safe API profile
      #
      # @example
      #   safe_profile = api.safe_me
      #   puts safe_profile['user_id']
      #
      def safe_me(access_token: nil)
        path = '/safe/me'
        client.get path, access_token:
      end
    end
  end
end
