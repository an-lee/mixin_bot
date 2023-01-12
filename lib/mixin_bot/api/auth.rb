# frozen_string_literal: true

module MixinBot
  class API
    module Auth
      def access_token(method, uri, body = '', exp_in: 600, scp: 'FULL')
        sig = Digest::SHA256.hexdigest(method + uri + body.to_s)
        iat = Time.now.utc.to_i
        exp = (Time.now.utc + exp_in).to_i
        jti = SecureRandom.uuid
        payload = {
          uid: client_id,
          sid: session_id,
          iat: iat,
          exp: exp,
          jti: jti,
          sig: sig,
          scp: scp
        }
        case key_type
        when :ed25519
          jwk = JOSE::JWK.from_okp [:Ed25519, private_key]
          jws = JOSE::JWS.from({ 'alg' => 'EdDSA' })
        when :rsa
          jwk = JOSE::JWK.from_pem private_key
          jws = JOSE::JWS.from({ 'alg' => 'RS512' })
        end

        jwt = JOSE::JWT.from payload
        JOSE::JWT.sign(jwk, jws, jwt).compact
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
        scope ||= (MixinBot.scope || 'PROFILE:READ')
        format(
          'https://mixin.one/oauth/authorize?client_id=%<client_id>s&scope=%<scope>s',
          client_id: client_id,
          scope: scope
        )
      end

      def authorize_code(**kwargs)
        path = '/oauth/authorize'
        data = authorization_data(
          kwargs[:user_id],
          kwargs[:scope] || ['PROFILE:READ']
        )

        payload = {
          authorization_id: data['authorization_id'],
          scopes: data['scopes'],
          pin_base64: encrypt_pin(kwargs[:pin])
        }

        access_token = kwargs[:access_token]
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def authorization_data(user_id, scope = ['PROFILE:READ'])
        @_client_id = user_id
        @_scope = scope.join(' ')
        EM.run do
          start_blaze_connect do
            def on_open(ws, _event)
              ws.send write_ws_message(
                action: 'REFRESH_OAUTH_CODE',
                params: {
                  client_id: @_client_id,
                  scope: @_scope,
                  authorization_id: '',
                  code_challenge: ''
                }
              )
            end

            def on_message(ws, event)
              raw = JSON.parse read_ws_message(event.data)
              @_data = raw['data']
              ws.close
            end

            def on_close(_ws, _event)
              EM.stop_event_loop
            end
          end
        end
        @_data
      end
    end
  end
end
