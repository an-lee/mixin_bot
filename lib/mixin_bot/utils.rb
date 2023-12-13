# frozen_string_literal: true

require_relative './utils/nfo'
require_relative './utils/uuid'
require_relative './utils/transaction'

module MixinBot
  module Utils
    class << self
      MAGIC = [0x77, 0x77].freeze
      TX_VERSION = 2
      MAX_ENCODE_INT = 0xFFFF
      NULL_BYTES = [0x00, 0x00].freeze
      AGGREGATED_SIGNATURE_PREFIX = 0xFF01
      AGGREGATED_SIGNATURE_ORDINAY_MASK = [0x00].freeze
      AGGREGATED_SIGNATURE_SPARSE_MASK = [0x01].freeze

      def generate_unique_uuid(uuid_1, uuid_2)
        md5 = Digest::MD5.new
        md5 << [uuid_1, uuid_2].min
        md5 << [uuid_1, uuid_2].max
        digest = md5.digest
        digest6 = (digest[6].ord & 0x0f | 0x30).chr
        digest8 = (digest[8].ord & 0x3f | 0x80).chr
        cipher = digest[0...6] + digest6 + digest[7] + digest8 + digest[9..]

        UUID.new(raw: cipher).unpacked
      end

      def unique_uuid(*uuids)
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

      def hex_to_uuid(hex)
        UUID.new(hex: hex).unpacked
      end

      def encode_raw_transaction(tx)
        if tx.is_a? String
          begin
            tx = JSON.parse tx
          rescue JSON::ParserError
            tx
          end
        end

        raise ArgumentError, "#{tx} is not a valid json" unless tx.is_a? Hash
        tx = tx.with_indifferent_access

        Transaction.new(**tx).encode.hex
      end

      def decode_raw_transaction(hex)
        Transaction.new(hex: hex).decode.to_h
      end

      def nft_memo(collection, token, extra)
        MixinBot::Utils::Nfo.new(
          collection: collection,
          token: token,
          extra: extra
        ).mint_memo
      end

      def encode_uint_16(int)
        raise ArgumentError, "only support int #{int}" unless int.is_a?(Integer)
        raise ArgumentError, "int #{int} is larger than MAX_ENCODE_INT #{MAX_ENCODE_INT}" if int > MAX_ENCODE_INT

        [int].pack('S*').bytes.reverse
      end

      def encode_uint_32(int)
        [int].pack('L*').bytes.reverse
      end

      def encode_uint_64(int)
        [int].pack('Q*').bytes.reverse
      end

      def int_to_bytes(int)
        raise ArgumentError, 'not integer' unless int.is_a?(Integer)

        bytes = []
        loop do
          break if int === 0

          bytes.push int & 255
          int = int / (2**8) | 0
        end

        bytes.reverse
      end

      def bytes_to_int(bytes)
        int = 0
        bytes.each do |byte|
          int = int * (2**8) + byte
        end

        int
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

        (JOSE::JWA::Edwards25519Point.stdbase * (point.x.to_i)).encode
      end

      def sign(msg, key:)
        msg = Digest::Blake3.digest msg

        pub = self.generate_public_key key
        
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

        r_point = JOSE::JWA::Edwards25519Point.stdbase * (z_point.x.to_i)
        hram_digest = Digest::SHA512.digest(r_point.encode + pub + msg)

        x_point = JOSE::JWA::FieldElement.new(
          OpenSSL::BN.new(hram_digest[...64].reverse, 2),
          JOSE::JWA::Edwards25519Point::L
        )
        s_point = (x_point * y_point) + z_point

        r_point.encode + s_point.to_bytes(36)
      end
    end
  end
end
