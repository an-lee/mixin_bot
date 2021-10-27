# frozen_string_literal: true

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
      NFT_MEMO_PREFIX = 'NFO'
      NFT_MEMO_VERSION = 0x00
      NFT_MEMO_DEFAULT_CHAIN = '43d61dcd-e413-450d-80b8-101d5e903357'
      NFT_MEMO_DEFAULT_CLASS = '3c8c161a18ae2c8b14fda1216fff7da88c419b5d'
      NFT_MASK = 0x00
      NULL_UUID = '00000000-0000-0000-0000-000000000000'

      def unique_uuid(user_id, opponent_id = nil)
        opponent_id ||= client_id
        md5 = Digest::MD5.new
        md5 << [user_id, opponent_id].min
        md5 << [user_id, opponent_id].max
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

        tx = tx.with_indifferent_access
        bytes = []

        # magic number
        bytes += MAGIC

        # version
        bytes += [0, tx['version']]
        bytes += [tx['asset']].pack('H*').bytes

        # inputs
        bytes += encode_inputs tx['inputs']

        # output
        bytes += encode_outputs tx['outputs']

        # extra
        extra_bytes = [tx['extra']].pack('H*').bytes
        bytes += encode_int extra_bytes.size
        bytes += extra_bytes

        # aggregated
        aggregated = tx['aggregated']
        if aggregated.nil?
          # signatures
          bytes += encode_signatures tx['signatures']
        else
          bytes += encode_aggregated_signature aggregated
        end

        bytes.pack('C*').unpack1('H*')
      end

      def nft_memo_hash(collection, token_id, meta)
        collection = NULL_UUID if collection.empty?
        meta = meta.to_json if meta.is_a?(Hash)

        memo = {
          prefix: NFT_MEMO_PREFIX,
          version: NFT_MEMO_VERSION,
          mask: 0,
          chain: NFT_MEMO_DEFAULT_CHAIN,
          class: NFT_MEMO_DEFAULT_CLASS,
          collection: collection,
          token: token_id,
          extra: SHA3::Digest::SHA256.hexdigest(meta)
        }

        mark = [0]
        mark.map do |index|
          if index >= 64
            raise "invalid NFO memo index #{index}"
          end
          memo[:mask] = memo[:mask] ^ (1 << index)
        end

        memo
      end

      def nft_memo(collection, token_id, meta)
        encode_nft_memo nft_memo_hash(collection, token_id, meta)
      end

      def encode_nft_memo(memo)
        bytes = []

        bytes += NFT_MEMO_PREFIX.bytes 
        bytes += [NFT_MEMO_VERSION]

        if memo[:mask] != 0
          bytes += [1]
          bytes += encode_unit_64 memo[:mask]
          bytes += memo[:chain].split('-').pack('H* H* H* H* H*').bytes

          class_bytes = [memo[:class]].pack('H*').bytes
          bytes += bytes_of class_bytes.size
          bytes += class_bytes

          collection_bytes = memo[:collection].split('-').pack('H* H* H* H* H*').bytes
          bytes += bytes_of collection_bytes.size
          bytes += collection_bytes

          # token_bytes = memo[:token].split('-').pack('H* H* H* H* H*').bytes
          token_bytes = bytes_of memo[:token]
          bytes += bytes_of token_bytes.size
          bytes += token_bytes
        end

        extra_bytes = [memo[:extra]].pack('H*').bytes
        bytes += bytes_of extra_bytes.size
        bytes += extra_bytes

        Base64.urlsafe_encode64 bytes.pack('C*'), padding: false
      end

      def decode_nft_memo(encoded)
        bytes = Base64.urlsafe_decode64(encoded).bytes
        memo = {}
        memo[:prefix] = bytes.shift(3).pack('C*')
        memo[:version] = bytes.shift

        hint = bytes.shift
        if hint == 1
          memo[:mask] = bytes.shift(8).reverse.pack('C*').unpack1('Q*')
          memo[:chain] = hex_to_uuid bytes.shift(16).pack('C*').unpack1('H*')

          class_length = bytes.shift
          memo[:class] = bytes.shift(class_length).pack('C*').unpack1('H*')

          collection_length = bytes.shift
          memo[:collection] = hex_to_uuid bytes.shift(collection_length).pack('C*').unpack1('H*')

          token_length = bytes.shift
          memo[:token] = bytes_to_int bytes.shift(token_length)
        end

        extra_length = bytes.shift
        memo[:extra] = bytes.shift(extra_length).pack('C*').unpack1('H*')

        memo
      end

      private

      def encode_int(int)
        raise "only support int #{int}" unless int.is_a?(Integer)
        raise "int #{int} is larger than MAX_ENCODE_INT #{MAX_ENCODE_INT}" if int > MAX_ENCODE_INT

        [int].pack('S*').bytes.reverse
      end

      def encode_unit_64(int)
        [int].pack('Q*').bytes.reverse
      end

      def bytes_of(int)
        raise 'not integer' unless int.is_a?(Integer)

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

      def encode_inputs(inputs, bytes = [])
        bytes += encode_int(inputs.size)
        inputs.each do |input|
          bytes += [input['hash']].pack('H*').bytes
          bytes += encode_int(input['index'])

          # genesis
          genesis = input['genesis'] || ''
          if genesis.empty?
            bytes += encode_int 0
          else
            genesis_bytes = [genesis].pack('H*')
            bytes += encode_int genesis_bytes.size
            bytes += genesis_bytes
          end

          # deposit
          deposit = input['deposit']
          if deposit.nil?
            bytes += NULL_BYTES
          else
            bytes += MAGIC
            bytes += [deposit['chain']].pack('H*').bytes

            asset_bytes = [deposit['asset']].pack('H*')
            bytes += encode_int asset_bytes.size
            bytes += asset_bytes

            transaction_bytes = [deposit['transaction']].pack('H*')
            bytes += encode_int transaction_bytes.size
            bytes += transaction_bytes

            bytes += encode_unit_64 deposit['index']

            amount_bytes = bytes_of deposit['amount']
            bytes +=  encode_int amount_bytes.size
            bytes +=  amount_bytes
          end

          # mint
          mint = input['mint']
          if mint.nil?
            bytes += NULL_BYTES
          else
            bytes += MAGIC

            # group
            group = mint['group'] || ''
            if group.empty?
              bytes += encode_int 0
            else
              group_bytes = [group].pack('H*')
              bytes += encode_int group_bytes.size
              bytes += group_bytes
            end

            bytes += encode_unit_64 mint['batch']

            amount_bytes = bytes_of mint['amount']
            bytes +=  encode_int amount_bytes.size
            bytes +=  amount_bytes
          end
        end

        bytes
      end

      def encode_outputs(outputs, bytes = [])
        bytes += encode_int(outputs.size)
        outputs.each do |output|
          type = output['type'] || 0
          bytes += [0x00, type]

          # amount
          amount_bytes = bytes_of (output['amount'].to_f * 1e8).to_i
          bytes +=  encode_int amount_bytes.size
          bytes +=  amount_bytes

          # keys
          bytes +=  encode_int output['keys'].size
          output['keys'].each do |key|
            bytes += [key].pack('H*').bytes
          end

          # mask
          bytes += [output['mask']].pack('H*').bytes

          # script
          script_bytes = [output['script']].pack('H*').bytes
          bytes += encode_int script_bytes.size
          bytes += script_bytes

          # withdrawal
          withdrawal = output['withdrawal']
          if withdrawal.nil?
            bytes += NULL_BYTES
          else
            bytes += MAGIC

            # chain
            bytes += [withdrawal['chain']].pack('H*').bytes

            # asset
            asset_bytes = [withdrawal['asset']].pack('H*')
            bytes += encode_int asset_bytes.size
            bytes += asset_bytes

            # address
            address = withdrawal['address'] || ''
            if address.empty?
              bytes += NULL_BYTES
            else
              address_bytes = [address].pack('H*').bytes
              bytes += encode_int address.size
              bytes += address_bytes
            end

            # tag
            tag = withdrawal['tag'] || ''
            if tag.empty?
              bytes += NULL_BYTES
            else
              address_bytes = [tag].pack('H*').bytes
              bytes += encode_int tag.size
              bytes += address_bytes
            end
          end
        end

        bytes
      end

      def encode_aggregated_signature(aggregated, bytes = [])
        bytes += MAX_ENCODE_INT
        bytes += encode_int AGGREGATED_SIGNATURE_PREFIX
        bytes += [aggregated['signature']].pack('H*').bytes

        signers = aggregated['signers']
        if signers.size == 0
          bytes += AGGREGATED_SIGNATURE_ORDINAY_MASK
          bytes += encode_int 0
        else
          signers.each do |sig, i|
            raise 'signers not sorted' if i > 0 && sig <= signers[i - 1]
            raise 'signers not sorted' if sig > MAX_ENCODE_INT
          end

          max = signers.last
          if (((max / 8 | 0) + 1 | 0) > aggregated['signature'].size * 2)
            bytes += AGGREGATED_SIGNATURE_SPARSE_MASK
            bytes += encode_int aggregated['signature'].size
            signers.map(&->(signer) { bytes += encode_int(signer) })
          end

          masks_bytes = Array.new(max / 8 + 1, 0)
          signers.each do |signer|
            masks[signer/8] = masks[signer/8] ^ (1 << (signer % 8))
          end
          bytes += AGGREGATED_SIGNATURE_ORDINAY_MASK
          bytes += encode_int masks_bytes.size
          bytes += masks_bytes
        end

        bytes
      end

      def encode_signatures(signatures, bytes = [])
        sl =
          if signatures.is_a? Hash
            signatures.keys.size
          else
            0
          end

        raise 'signatures overflow' if sl == MAX_ENCODE_INT
        bytes += encode_int sl

        if sl > 0
          bytes += encode_int signatures.keys.size
          signatures.keys.sort.each do |key|
            bytes += encode_int key
            bytes += [signatures[key]].pack('H*').bytes
          end
        end

        bytes
      end
    end
  end
end
