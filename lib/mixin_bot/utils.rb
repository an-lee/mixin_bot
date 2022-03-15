# frozen_string_literal: true

require_relative './utils/nfo'
require_relative './utils/uuid'
require_relative './utils/transaction'

module MixinBot
  module Utils
    class << self
      MAGIC = [0x77, 0x77]
      TX_VERSION = 2
      MAX_ENCODE_INT = 0xFFFF
      NULL_BYTES = [0x00, 0x00]
      AGGREGATED_SIGNATURE_PREFIX = 0xFF01
      AGGREGATED_SIGNATURE_ORDINAY_MASK = [0x00]
      AGGREGATED_SIGNATURE_SPARSE_MASK = [0x01]

      def generate_unique_uuid(uuid_1, uuid_2)
        md5 = Digest::MD5.new
        md5 << [uuid_1, uuid_2].min
        md5 << [uuid_1, uuid_2].max
        digest = md5.digest
        digest6 = (digest[6].ord & 0x0f | 0x30).chr
        digest8 = (digest[8].ord & 0x3f | 0x80).chr
        cipher = digest[0...6] + digest6 + digest[7] + digest8 + digest[9..]
        hex = cipher.unpack1('H*')

        format(
          '%<first>s-%<second>s-%<third>s-%<forth>s-%<fifth>s',
          first: hex[0..7],
          second: hex[8..11],
          third: hex[12..15],
          forth: hex[16..19],
          fifth: hex[20..]
        )
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
        hex = digest.unpack1('H*')

        hex_to_uuid hex
      end

      def hex_to_uuid(hex)
        [hex[0..7], hex[8..11], hex[12..15], hex[16..19], hex[20..]].join('-')
      end

      def sign_raw_transaction(tx)
        if tx.is_a? String
          tx = JSON.parse tx
        end
        raise ArgumentError, "#{tx} is not a valid json" unless tx.is_a? Hash

        tx = tx.with_indifferent_access

        Transaction.new(
          asset: tx[:asset],
          inputs: tx[:inputs],
          outputs: tx[:outputs],
          extra: tx[:extra],
        ).encode.hex
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

      def encode_int(int)
        raise ArgumentError, "only support int #{int}" unless int.is_a?(Integer)
        raise ArgumentError,"int #{int} is larger than MAX_ENCODE_INT #{MAX_ENCODE_INT}" if int > MAX_ENCODE_INT

        [int].pack('S*').bytes.reverse
      end

      def encode_unit_64(int)
        [int].pack('Q*').bytes.reverse
      end

      def bytes_of(int)
        raise ArgumentError, 'not integer' unless int.is_a?(Integer)

        bytes = []
        loop do
          break if int === 0
          bytes.push int & 255
          int = int / (2 ** 8) | 0
        end

        bytes.reverse
      end

      def bytes_to_int(bytes)
        int = 0
        bytes.each do |byte|
          int = int * (2 ** 8) + byte
        end

        int
      end
    end
  end
end
