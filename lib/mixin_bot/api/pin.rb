# frozen_string_literal: true

module MixinBot
  class API
    module Pin
      # https://developers.mixin.one/api/alpha-mixin-network/verify-pin/
      def verify_pin(pin_code)
        path = '/pin/verify'
        payload = {
          pin: encrypt_pin(pin_code)
        }

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # TODO:
      # https://developers.mixin.one/api/alpha-mixin-network/create-pin/
      def update_pin(old_pin:, new_pin:)
        path = '/pin/update'
        payload = {
          old_pin: old_pin.nil? ? '' : encrypt_pin(old_pin),
          pin: encrypt_pin(new_pin)
        }

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # decrypt the encrpted pin, just for test
      def decrypt_pin(msg)
        msg = Base64.strict_decode64 msg
        iv = msg[0..15]
        cipher = msg[16..47]
        aes_key = JOSE::JWA::PKCS1.rsaes_oaep_decrypt('SHA256', pin_token, private_key, session_id)
        alg = 'AES-256-CBC'
        decode_cipher = OpenSSL::Cipher.new(alg)
        decode_cipher.decrypt
        decode_cipher.iv = iv
        decode_cipher.key = aes_key
        decoded = decode_cipher.update(cipher)
        decoded[0..5]
      end

      # https://developers.mixin.one/api/alpha-mixin-network/encrypted-pin/
      # use timestamp(timestamp) for iterator as default: must be bigger than the previous, the first time must be greater than 0. After a new session created, it will be reset to 0.
      def encrypt_pin(pin_code, iterator: nil)
        aes_key = JOSE::JWA::PKCS1.rsaes_oaep_decrypt('SHA256', pin_token, private_key, session_id)
        iterator ||= Time.now.utc.to_i
        tszero = iterator % 0x100
        tsone = (iterator % 0x10000) >> 8
        tstwo = (iterator % 0x1000000) >> 16
        tsthree = (iterator % 0x100000000) >> 24
        tsstring = tszero.chr + tsone.chr + tstwo.chr + tsthree.chr + "\0\0\0\0"
        encrypt_content = pin_code + tsstring + tsstring
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
        aes.key = aes_key
        aes.iv = iv
        cipher = aes.update(padded_content)
        msg = iv + cipher
        Base64.strict_encode64 msg
      end
    end
  end
end
