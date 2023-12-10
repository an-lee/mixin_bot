# frozen_string_literal: true

module MixinBot
  class API
    module Safe
      def safe_register(pin)
        path = '/safe/users'

        key = JOSE::JWA::Ed25519.keypair private_key[...32]
        public_key = key[0].unpack1('H*')

        hex = SHA3::Digest::SHA256.hexdigest client_id
        signature = Base64.urlsafe_encode64 JOSE::JWA::Ed25519.sign([hex].pack('H*'), key[1]), padding: false

        pin_base64 = encrypt_tip_pin pin, 'SEQUENCER:REGISTER:', client_id, public_key

        payload = {
          public_key: public_key,
          signature: signature,
          pin_base64: pin_base64 
        }

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def safe_profile(**options)
        path = '/safe/me'
        access_token = options[:access_token] || access_token('GET', path)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
    end
  end
end
