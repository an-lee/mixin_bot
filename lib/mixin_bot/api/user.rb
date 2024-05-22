# frozen_string_literal: true

module MixinBot
  class API
    module User
      def user(user_id, access_token: nil)
        path = format('/users/%<user_id>s', user_id:)
        client.get path, access_token:
      end

      def create_user(full_name, key: nil)
        keypair = JOSE::JWA::Ed25519.keypair key
        session_secret = Base64.urlsafe_encode64 keypair[0], padding: false
        private_key = keypair[1].unpack1('H*')

        path = '/users'
        payload = {
          full_name:,
          session_secret:
        }

        res = client.post path, **payload
        res.merge(private_key:).with_indifferent_access
      end

      def search_user(query, access_token: nil)
        path = format('/search/%<query>s', query:)

        client.get path, access_token:
      end

      def fetch_users(user_ids)
        path = '/users/fetch'
        user_ids = [user_ids] if user_ids.is_a? String
        payload = user_ids

        client.post path, *payload
      end

      def create_safe_user(name, private_key: nil, spend_key: nil)
        private_keypair = JOSE::JWA::Ed25519.keypair private_key
        private_key = private_keypair[1].unpack1('H*')

        spend_keypair = JOSE::JWA::Ed25519.keypair spend_key
        spend_key = spend_keypair[1].unpack1('H*')

        user = create_user name, key: private_keypair[1][...32]

        keystore = {
          app_id: user['data']['user_id'],
          session_id: user['data']['session_id'],
          private_key:,
          pin_token: user['data']['pin_token_base64'],
          spend_key: spend_keypair[1].unpack1('H*')
        }
        user_api = MixinBot::API.new(**keystore)

        user_api.update_pin pin: MixinBot.utils.tip_public_key(spend_keypair[0], counter: user['data']['tip_counter'])

        # wait for tip pin update in server
        sleep 1

        user_api.safe_register spend_key

        keystore
      end

      def safe_register(pin, spend_key: nil)
        path = '/safe/users'

        spend_key ||= MixinBot.utils.decode_key pin
        key = JOSE::JWA::Ed25519.keypair spend_key[...32]
        public_key = key[0].unpack1('H*')

        hex = SHA3::Digest::SHA256.hexdigest config.app_id
        signature = Base64.urlsafe_encode64 JOSE::JWA::Ed25519.sign([hex].pack('H*'), key[1]), padding: false

        pin_base64 = encrypt_tip_pin pin, 'SEQUENCER:REGISTER:', config.app_id, public_key

        payload = {
          public_key:,
          signature:,
          pin_base64:
        }

        client.post path, **payload
      end

      def migrate_to_safe(spend_key:, pin: nil)
        profile = me['data']
        return true if profile['has_safe']

        spend_keypair = JOSE::JWA::Ed25519.keypair spend_key
        spend_key = spend_keypair[1].unpack1('H*')

        if profile['tip_key_base64'].blank?
          new_pin = MixinBot.utils.tip_public_key(spend_keypair[0], counter: profile['tip_counter'])
          update_pin(pin: new_pin, old_pin: pin)

          pin = new_pin
        end

        # wait for tip pin update in server
        sleep 1

        safe_register pin, spend_key

        {
          spend_key:
        }.with_indifferent_access
      end
    end
  end
end
