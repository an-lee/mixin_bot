# frozen_string_literal: true

module MixinBot
  class API
    module Pin
      def verify_pin(pin_code, access_token = nil)
        path = '/pin/verify'
        payload = {
          pin: encrypt_pin(pin_code)
        }

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def update_pin(old_pincode, new_pincode)
        path = '/pin/update'
        payload = {
          old_pin: old_pincode.nil? ? '' : encrypt_pin(old_pincode),
          pin: encrypt_pin(new_pincode)
        }

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

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

      def encrypt_pin(pin_code)
        aes_key = JOSE::JWA::PKCS1.rsaes_oaep_decrypt('SHA256', pin_token, private_key, session_id)
        ts = Time.now.utc.to_i
        tszero = ts % 0x100
        tsone = (ts % 0x10000) >> 8
        tstwo = (ts % 0x1000000) >> 16
        tsthree = (ts % 0x100000000) >> 24
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
