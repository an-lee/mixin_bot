# frozen_string_literal: true

require_relative './utils/nfo'
require_relative './utils/uuid'

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
        bytes = []

        # magic number
        bytes += MAGIC

        # version
        bytes += [0, tx['version']]

        # asset
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

      def decode_raw_transaction(raw)
        bytes = [raw].pack('H*').bytes
        tx = {}

        magic = bytes.shift(2)
        raise ArgumentError, 'Not valid raw' unless magic == MAGIC

        version = bytes.shift(2)
        tx['version'] = bytes_to_int version

        asset = bytes.shift(32)
        tx['asset'] = asset.pack('C*').unpack1('H*')

        # read inputs
        bytes, tx = decode_inputs bytes, tx

        # read outputs
        bytes, tx = decode_outputs bytes, tx

        extra_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
        tx['extra'] = bytes.shift(extra_size).pack('C*').unpack1('H*')

        num = bytes.shift(2).reverse.pack('C*').unpack1('S*')
        if num == MAX_ENCODE_INT
          # aggregated
          aggregated = {}

          raise ArgumentError, 'invalid aggregated' unless bytes.shift(2).reverse.pack('C*').unpack1('S*') == AGGREGATED_SIGNATURE_PREFIX

          aggregated['signature'] = bytes.shift(64).pack('C*').unpack1('H*')

          byte = bytes.shift
          case byte
          when AGGREGATED_SIGNATURE_ORDINAY_MASK.first
            aggregated['signers'] = []
            masks_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
            masks = bytes.shift(masks_size)
            masks = [masks] unless masks.is_a? Array

            masks.each_with_index do |mask, i|
              8.times do |j|
                k = 1 << j
                aggregated['signers'].push(i * 8 + j) if mask & k == k
              end
            end
          when AGGREGATED_SIGNATURE_SPARSE_MASK.first
            signers_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
            return if signers_size == 0

            aggregated['signers'] = []
            signers_size.times do
              aggregated['signers'].push bytes.shift(2).reverse.pack('C*').unpack1('S*')
            end
          end

          tx['aggregated'] = aggregated
        else
          if !bytes.empty? && bytes[...2] != NULL_BYTES
            signatures_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
            tx['signatures'] = bytes.shift(signatures_size).pack('C*').unpack1('H*')
          end
        end
        
        tx
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

      def encode_inputs(inputs, bytes = [])
        bytes += encode_int(inputs.size)
        inputs.each do |input|
          bytes += [input['hash']].pack('H*').bytes
          bytes += encode_int(input['index'])

          # genesis
          genesis = input['genesis'] || ''
          if genesis.empty?
            bytes += NULL_BYTES
          else
            genesis_bytes = [genesis].pack('H*').bytes
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
              bytes += encode_int NULL_BYTES
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
          amount_bytes = bytes_of (output['amount'].to_f * 1e8).round
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
        bytes += encode_int MAX_ENCODE_INT
        bytes += encode_int AGGREGATED_SIGNATURE_PREFIX
        bytes += [aggregated['signature']].pack('H*').bytes

        signers = aggregated['signers']
        if signers.size == 0
          bytes += AGGREGATED_SIGNATURE_ORDINAY_MASK
          bytes += NULL_BYTES
        else
          signers.each do |sig, i|
            raise ArgumentError, 'signers not sorted' if i > 0 && sig <= signers[i - 1]
            raise ArgumentError, 'signers not sorted' if sig > MAX_ENCODE_INT
          end

          max = signers.last
          if (((max / 8 | 0) + 1 | 0) > aggregated['signature'].size * 2)
            bytes += AGGREGATED_SIGNATURE_SPARSE_MASK
            bytes += encode_int aggregated['signers'].size
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

        raise ArgumentError, 'signatures overflow' if sl == MAX_ENCODE_INT
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

      def decode_inputs(bytes, tx)
        inputs_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
        tx['inputs'] = []
        inputs_size.times do
          input = {}
          hash = bytes.shift(32)
          input['hash'] = hash.pack('C*').unpack1('H*')

          index = bytes.shift(2)
          input['index'] = index.reverse.pack('C*').unpack1('S*')

          if bytes[...2] != NULL_BYTES
            genesis_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
            genesis = bytes.shift(genesis_size)
            input['genesis'] = genesis.pack('C*').unpack1('H*')
          else
            bytes.shift 2
          end

          if bytes[...2] != NULL_BYTES
            magic = bytes.shift(2)
            raise ArgumentError, 'Not valid input' unless magic == MAGIC

            deposit = {}
            deposit['chain'] = bytes.shift(32).pack('C*').unpack1('H*')

            asset_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
            deposit['asset'] = bytes.shift(asset_size).unpack1('H*')

            transaction_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
            deposit['transaction'] = bytes.shift(transaction_size).unpack1('H*')

            deposit['index'] = bytes.shift(8).reverse.pack('C*').unpack1('Q*')

            amount_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
            deposit['amount'] = bytes_to_int bytes.shift(amount_size)

            input['deposit'] = deposit
          else
            bytes.shift 2
          end

          if bytes[...2] != NULL_BYTES
            magic = bytes.shift(2)
            raise ArgumentError, 'Not valid input' unless magic == MAGIC

            mint = {}
            if bytes[...2] != NULL_BYTES
              group_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
              mint['group'] = bytes.shift(group_size).unpack1('H*')
            else
              bytes.shift 2
            end

            mint['batch'] = bytes.shift(8).reverse.pack('C*').unpack1('Q*')
            _amount_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
            mint['amount'] = bytes_to_int bytes.shift(_amount_size)

            input['mint'] = mint
          else
            bytes.shift 2
          end

          tx['inputs'].push input
        end

        [bytes, tx]
      end

      def decode_outputs(bytes, tx)
        outputs_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
        tx['outputs'] = []
        outputs_size.times do
          output = {}

          bytes.shift
          type = bytes.shift
          output['type'] = type

          amount_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
          output['amount'] = format('%.8f', bytes_to_int(bytes.shift(amount_size)).to_f / 1e8)

          output['keys'] = []
          keys_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
          keys_size.times do
            output['keys'].push bytes.shift(32).pack('C*').unpack1('H*')
          end

          output['mask'] = bytes.shift(32).pack('C*').unpack1('H*')

          script_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
          output['script'] = bytes.shift(script_size).pack('C*').unpack1('H*')

          if bytes[...2] != NULL_BYTES
            magic = bytes.shift(2)
            raise ArgumentError, 'Not valid output' unless magic == MAGIC

            withdraw = {}

            output['chain'] = bytes.shift(32).pack('C*').unpack1('H*')

            asset_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
            output['asset'] = bytes.shift(asset_size).unpack1('H*')

            if bytes[...2] != NULL_BYTES
              address = {}

              adderss_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
              output['adderss'] = bytes.shift(adderss_size).pack('C*').unpack1('H*')
            else
              bytes.shift 2
            end

            if bytes[...2] != NULL_BYTES
              tag = {}

              tag_size = bytes.shift(2).reverse.pack('C*').unpack1('S*')
              output['tag'] = bytes.shift(tag_size).pack('C*').unpack1('H*')
            else
              bytes.shift 2
            end
          else
            bytes.shift 2
          end

          tx['outputs'].push output
        end

        [bytes, tx]
      end
    end
  end
end
