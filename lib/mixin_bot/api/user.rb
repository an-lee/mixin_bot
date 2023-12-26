# frozen_string_literal: true

module MixinBot
  class API
    module User
      # https://developers.mixin.one/api/beta-mixin-message/read-user/
      def read_user(user_id)
        # user_id: Mixin User UUID
        path = format('/users/%<user_id>s', user_id:)
        access_token = access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token:)
        client.get(path, headers: { Authorization: authorization })
      end

      # https://developers.mixin.one/api/alpha-mixin-network/app-user/
      # Create a new Mixin Network user (like a normal Mixin Messenger user). You should keep PrivateKey which is used to sign an AuthenticationToken and encrypted PIN for the user.
      def create_user(full_name, key: nil)
        key || MixinBot::Utils.generate_ed25519_key
        session_secret = ed25519_key[:public_key]

        payload = {
          full_name:,
          session_secret:
        }
        access_token = access_token('POST', '/users', payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token:)
        res = client.post('/users', headers: { Authorization: authorization }, json: payload)

        res.merge(rsa_key:, ed25519_key:)
      end

      # https://developers.mixin.one/api/beta-mixin-message/search-user/
      # search by Mixin Id or Phone Number
      def search_user(query)
        path = format('/search/%<query>s', query:)

        access_token = access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token:)
        client.get(path, headers: { Authorization: authorization })
      end

      # https://developers.mixin.one/api/beta-mixin-message/read-users/
      def fetch_users(user_ids)
        # user_ids: a array of user_ids
        path = '/users/fetch'
        user_ids = [user_ids] if user_ids.is_a? String
        payload = user_ids

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token:)
        client.post(path, headers: { Authorization: authorization }, json: payload)
      end

      def safe_register(pin, spend_key:)
        path = '/safe/users'

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

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token:)
        client.post(path, headers: { Authorization: authorization }, json: payload)
      end
    end
  end
end
