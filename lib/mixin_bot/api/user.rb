# frozen_string_literal: true

module MixinBot
  class API
    module User
      # https://developers.mixin.one/api/beta-mixin-message/read-user/
      def read_user(user_id)
        # user_id: Mixin User UUID
        path = format('/users/%<user_id>s', user_id: user_id)
        access_token = access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      # https://developers.mixin.one/api/alpha-mixin-network/app-user/
      # Create a new Mixin Network user (like a normal Mixin Messenger user). You should keep PrivateKey which is used to sign an AuthenticationToken and encrypted PIN for the user.
      def create_user(full_name, rsa_key = nil)
        rsa_key ||= generate_rsa_key
        session_secret = rsa_key[:public_key]
        session_secret.gsub!(/^-----.*PUBLIC KEY-----$/, '').strip!

        payload = {
          full_name: full_name,
          session_secret: session_secret
        }

        access_token = access_token('POST', '/users', payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        res = client.post('/users', headers: { 'Authorization': authorization }, json: payload)

        res.merge(rsa_key: rsa_key)
      end

      def generate_rsa_key
        rsa_key = OpenSSL::PKey::RSA.new 1024
        {
          private_key: rsa_key.to_pem,
          public_key: rsa_key.public_key.to_pem
        }
      end
      
      # https://developers.mixin.one/api/beta-mixin-message/search-user/
      # search by Mixin Id or Phone Number
      def search_user(query)
        path = format('/search/%<query>s', query: query)

        access_token = access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      # https://developers.mixin.one/api/beta-mixin-message/read-users/
      def fetch_users(user_ids)
        # user_ids: a array of user_ids
        path = '/users/fetch'
        user_ids = [user_ids] if user_ids.is_a? String
        payload = user_ids

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end
    end
  end
end
