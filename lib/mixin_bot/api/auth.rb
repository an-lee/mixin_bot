# frozen_string_literal: true

module MixinBot
  class API
    module Auth
      def access_token(method, uri, body = '', exp_in = 600)
        sig = Digest::SHA256.hexdigest(method + uri + body)
        iat = Time.now.utc.to_i
        exp = (Time.now.utc + exp_in).to_i
        jti = SecureRandom.uuid
        payload = {
          uid: client_id,
          sid: session_id,
          iat: iat,
          exp: exp,
          jti: jti,
          sig: sig
        }
        JWT.encode payload, private_key, 'RS512'
      end

      def oauth_token(code)
        path = 'oauth/token'
        payload = {
          client_id: client_id,
          client_secret: client_secret,
          code: code
        }
        r = client.post(path, json: payload)

        raise r.inspect if r['error'].present?

        r['data']&.[]('access_token')
      end

      def request_oauth(scope = nil)
        scope ||= (MixinBot.scope || 'PROFILE:READ+PHONE:READ')
        format(
          'https://mixin.one/oauth/authorize?client_id=%<client_id>s&scope=%<scope>s',
          client_id: client_id,
          scope: scope
        )
      end
    end
  end
end
