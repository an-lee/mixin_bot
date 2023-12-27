# frozen_string_literal: true

module MixinBot
  module Utils
    module Crypto
      def access_token(method, uri, body = '', **kwargs)
        sig = Digest::SHA256.hexdigest(method + uri + body.to_s)
        iat = Time.now.utc.to_i
        exp = (Time.now.utc + (kwargs[:exp_in] || 600)).to_i
        scp = kwargs[:scp] || 'FULL'
        jti = SecureRandom.uuid
        uid = kwargs[:app_id] || MixinBot.config.app_id
        sid = kwargs[:session_id] || MixinBot.config.session_id
        private_key = kwargs[:private_key] || MixinBot.config.session_private_key

        payload = {
          uid:,
          sid:,
          iat:,
          exp:,
          jti:,
          sig:,
          scp:
        }

        if private_key.blank?
          raise ConfigurationNotValidError, 'private_key is required'
        elsif private_key.size == 64
          jwk = JOSE::JWK.from_okp [:Ed25519, private_key]
          jws = JOSE::JWS.from({ 'alg' => 'EdDSA' })
        else
          jwk = JOSE::JWK.from_pem private_key
          jws = JOSE::JWS.from({ 'alg' => 'RS512' })
        end

        jwt = JOSE::JWT.from payload
        JOSE::JWT.sign(jwk, jws, jwt).compact
      end

      def generate_ed25519_key
        ed25519_key = JOSE::JWA::Ed25519.keypair
        {
          private_key: Base64.strict_encode64(ed25519_key[1]),
          public_key: Base64.strict_encode64(ed25519_key[0])
        }
      end

      def generate_rsa_key
        rsa_key = OpenSSL::PKey::RSA.new 1024
        {
          private_key: rsa_key.to_pem,
          public_key: rsa_key.public_key.to_pem
        }
      end

      def generate_public_key(key)
        point = JOSE::JWA::FieldElement.new(
          OpenSSL::BN.new(key.reverse, 2),
          JOSE::JWA::Edwards25519Point::L
        )

        (JOSE::JWA::Edwards25519Point.stdbase * point.x.to_i).encode
      end

      def sign(msg, key:)
        msg = Digest::Blake3.digest msg

        pub = generate_public_key key

        y_point = JOSE::JWA::FieldElement.new(
          OpenSSL::BN.new(key.reverse, 2),
          JOSE::JWA::Edwards25519Point::L
        )

        key_digest = Digest::SHA512.digest key
        msg_digest = Digest::SHA512.digest(key_digest[-32...] + msg)

        z_point = JOSE::JWA::FieldElement.new(
          OpenSSL::BN.new(msg_digest[...64].reverse, 2),
          JOSE::JWA::Edwards25519Point::L
        )

        r_point = JOSE::JWA::Edwards25519Point.stdbase * z_point.x.to_i
        hram_digest = Digest::SHA512.digest(r_point.encode + pub + msg)

        x_point = JOSE::JWA::FieldElement.new(
          OpenSSL::BN.new(hram_digest[...64].reverse, 2),
          JOSE::JWA::Edwards25519Point::L
        )
        s_point = (x_point * y_point) + z_point

        r_point.encode + s_point.to_bytes(36)
      end

      def generate_unique_uuid(uuid_1, uuid_2)
        md5 = Digest::MD5.new
        md5 << [uuid_1, uuid_2].min
        md5 << [uuid_1, uuid_2].max
        digest = md5.digest
        digest6 = ((digest[6].ord & 0x0f) | 0x30).chr
        digest8 = ((digest[8].ord & 0x3f) | 0x80).chr
        cipher = digest[0...6] + digest6 + digest[7] + digest8 + digest[9..]

        UUID.new(raw: cipher).unpacked
      end

      def unique_uuid(*uuids)
        uuids = uuids.flatten.compact
        uuids.sort
        r = uuids.first
        uuids.each_with_index do |uuid, i|
          r = MixinBot::Utils.generate_unique_uuid(r, uuid) if i.positive?
        end

        r
      end

      def generate_trace_from_hash(hash, output_index = 0)
        md5 = Digest::MD5.new
        md5 << hash
        md5 << [output_index].pack('c*') if output_index.positive? && output_index < 256
        digest = md5.digest
        digest[6] = ((digest[6].ord & 0x0f) | 0x30).chr
        digest[8] = ((digest[8].ord & 0x3f) | 0x80).chr

        UUID.new(raw: digest).unpacked
      end
    end
  end
end
