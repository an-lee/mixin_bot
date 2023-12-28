# frozen_string_literal: true

module MixinBot
  class API
    module User
      def user(user_id, access_token: nil)
        path = format('/users/%<user_id>s', user_id:)
        client.get path, access_token:
      end
      alias read_user user

      def create_user(full_name, key: nil)
        key ||= MixinBot.utils.generate_ed25519_key
        session_secret = key[:public_key]

        path = '/users'
        payload = {
          full_name:,
          session_secret:
        }

        res = client.post path, **payload
        res.merge(key:)
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
    end
  end
end
