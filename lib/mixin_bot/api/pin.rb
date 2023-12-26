# frozen_string_literal: true

module MixinBot
  class API
    module Pin
      # https://developers.mixin.one/api/alpha-mixin-network/verify-pin/
      def verify_pin(pin = nil)
        pin ||= MixinBot.config.pin
        raise ArgumentError, 'invalid pin' if pin.blank?

        path = '/pin/verify'

        payload = 
          if pin.length > 6
            timestamp = Time.now.utc.to_i
            pin_base64 = encrypt_tip_pin pin, 'TIP:VERIFY:', timestamp.to_s.rjust(32, '0')

            {
              pin_base64: pin_base64,
              timestamp: timestamp,
            }
          else 
            {
              pin: encrypt_pin(pin)
            }
          end

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # https://developers.mixin.one/api/alpha-mixin-network/create-pin/
      def update_pin(old_pin: nil, pin:)
        old_pin ||= MixinBot.config.pin
        raise ArgumentError, 'invalid old pin' if old_pin.present? && old_pin.length != 6

        path = '/pin/update'
        encrypted_old_pin = old_pin.nil? ? '' : encrypt_pin(old_pin, iterator: Time.now.utc.to_i)

        encrypted_pin = encrypt_pin(pin, iterator: Time.now.utc.to_i + 1)
        payload = {
          old_pin_base64: encrypted_old_pin,
          pin_base64: encrypted_pin
        }

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def prepare_tip_key(counter = 0)
        ed25519_key = JOSE::JWA::Ed25519.keypair

        _private_key = ed25519_key[1].unpack1('H*')
        public_key = (ed25519_key[0].bytes + MixinBot::Utils.encode_uint_64(counter + 1)).pack('c*').unpack1('H*')

        {
          private_key: _private_key,
          public_key: public_key
        }
      end

      # decrypt the encrpted pin, just for test
      def decrypt_pin(msg)
        msg = Base64.urlsafe_decode64 msg
        iv = msg[0..15]
        cipher = msg[16..47]
        alg = 'AES-256-CBC'
        decode_cipher = OpenSSL::Cipher.new(alg)
        decode_cipher.decrypt
        decode_cipher.iv = iv
        decode_cipher.key = _generate_aes_key
        decoded = decode_cipher.update(cipher)
        decoded
      end

      # https://developers.mixin.one/api/alpha-mixin-network/encrypted-pin/
      # use timestamp(timestamp) for iterator as default: must be bigger than the previous, the first time must be greater than 0. After a new session created, it will be reset to 0.
      def encrypt_pin(pin, iterator: nil)
        pin = MixinBot::Utils.decode_key pin

        iterator ||= Time.now.utc.to_i
        tszero = iterator % 0x100
        tsone = (iterator % 0x10000) >> 8
        tstwo = (iterator % 0x1000000) >> 16
        tsthree = (iterator % 0x100000000) >> 24
        tsstring = "#{tszero.chr}#{tsone.chr}#{tstwo.chr}#{tsthree.chr}\u0000\u0000\u0000\u0000"
        encrypt_content = 
          if pin.length > 6
            pin + tsstring + tsstring
          else
            pin + tsstring + tsstring
          end
        pad_count = 16 - encrypt_content.length % 16
        padded_content =
          if pad_count.positive?
            encrypt_content + pad_count.chr * pad_count
          else
            encrypt_content
          end

        alg = 'AES-256-CBC'
        aes = OpenSSL::Cipher.new(alg)
        iv = OpenSSL::Cipher.new(alg).random_iv
        aes.encrypt
        aes.key = _generate_aes_key
        aes.iv = iv
        cipher = aes.update(padded_content)
        msg = iv + cipher
        Base64.urlsafe_encode64 msg, padding: false
      end
    end

    private

    def _generate_aes_key
      if config.server_public_key.size == 32
        JOSE::JWA::X25519.x25519(
          JOSE::JWA::Ed25519.secret_to_curve25519(config.session_private_key[0...32]), 
          config.server_public_key
        )
      else
        JOSE::JWA::PKCS1.rsaes_oaep_decrypt(
          'SHA256',
          config.server_public_key,
          OpenSSL::PKey::RSA.new(config.session_private_key),
          session_id
        )
      end
    end
  end
end
