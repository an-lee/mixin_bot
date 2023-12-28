# frozen_string_literal: true

module MixinBot
  module Utils
    module Encoder
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

        MixinBot::Transaction.new(**tx).encode.hex
      end

      def encode_uint_16(int)
        raise ArgumentError, "only support int #{int}" unless int.is_a?(Integer)

        [int].pack('S*').bytes.reverse
      end

      def encode_uint_32(int)
        raise ArgumentError, "only support int #{int}" unless int.is_a?(Integer)

        [int].pack('L*').bytes.reverse
      end

      def encode_uint_64(int)
        raise ArgumentError, "only support int #{int}" unless int.is_a?(Integer)

        [int].pack('Q*').bytes.reverse
      end

      def encode_int(int)
        raise ArgumentError, 'not integer' unless int.is_a?(Integer)

        bytes = []
        loop do
          break if int === 0

          bytes.push int & 255
          int = (int / (2**8)) | 0
        end

        bytes.reverse
      end

      def nft_memo(collection, token, extra)
        MixinBot::Nfo.new(
          collection:,
          token:,
          extra:
        ).mint_memo
      end
    end
  end
end
