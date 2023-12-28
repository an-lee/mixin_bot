# frozen_string_literal: true

module MixinBot
  module Utils
    module Decoder
      def decode_key(key)
        return if key.blank?

        if key.match?(/\A[\h]{64,}\z/i)
          [key].pack('H*')
        elsif key.match?(/\A[a-zA-Z0-9\-\_=]{43,}\z/)
          Base64.urlsafe_decode64 key
        elsif key.match?(/^-----BEGIN RSA PRIVATE KEY-----/)
          key.gsub('\\r\\n', "\n").gsub("\r\n", "\n")
        elsif key.match?(/\d{6}/) || (key.size % 32).zero?
          key
        else
          raise ArgumentError, "Invalid key #{key}"
        end
      end

      def decode_raw_transaction(hex)
        MixinBot::Transaction.new(hex:).decode.to_h
      end

      def decode_uint_16(bytes)
        raise ArgumentError, "only support bytes #{bytes}" unless bytes.is_a?(Array)

        bytes.reverse.pack('C*').unpack1('S*')
      end

      def decode_uint_32(bytes)
        raise ArgumentError, "only support bytes #{bytes}" unless bytes.is_a?(Array)

        bytes.reverse.pack('C*').unpack1('L*')
      end

      def decode_uint_64(bytes)
        raise ArgumentError, "only support bytes #{bytes}" unless bytes.is_a?(Array)

        bytes.reverse.pack('C*').unpack1('Q*')
      end

      def decode_int(bytes)
        int = 0
        bytes.each do |byte|
          int = (int * (2**8)) + byte
        end

        int
      end

      def hex_to_uuid(hex)
        MixinBot::UUID.new(hex:).unpacked
      end
    end
  end
end
