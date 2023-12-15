# frozen_string_literal: true

module MixinBot
  module Utils
    class Transaction
      DEAULT_VERSION = 5
      MAGIC = [0x77, 0x77]
      TX_VERSION = 2
      MAX_ENCODE_INT = 0xFFFF
      MAX_EXTRA_SIZE = 512
      NULL_BYTES = [0x00, 0x00]
      AGGREGATED_SIGNATURE_PREFIX = 0xFF01
      AGGREGATED_SIGNATURE_ORDINAY_MASK = [0x00]
      AGGREGATED_SIGNATURE_SPARSE_MASK = [0x01]

      attr_accessor :version, :asset, :inputs, :outputs, :extra, :signatures, :aggregated, :references, :hex, :hash

      def initialize(**kwargs)
        @version = kwargs[:version] || DEAULT_VERSION
        @asset = kwargs[:asset]
        @inputs = kwargs[:inputs]
        @outputs = kwargs[:outputs]
        @extra = kwargs[:extra].to_s
        @hex = kwargs[:hex]
        @signatures = kwargs[:signatures]
        @aggregated = kwargs[:aggregated]
        @references = kwargs[:references]
      end

      def encode
        raise InvalidTransactionFormatError, 'asset is required' if asset.blank?
        raise InvalidTransactionFormatError, 'inputs is required' if inputs.blank?
        raise InvalidTransactionFormatError, 'outputs is required' if outputs.blank?

        bytes = []

        # magic number
        bytes += MAGIC

        # version
        bytes += [0, version]

        # asset
        bytes += [asset].pack('H*').bytes

        # inputs
        bytes += encode_inputs

        # output
        bytes += encode_outputs

        # placeholder for `references`
        bytes += NULL_BYTES

        # extra
        extra_bytes = extra.bytes
        raise InvalidTransactionFormatError, 'extra is too long' if extra_bytes.size > MAX_EXTRA_SIZE
        bytes += MixinBot::Utils.encode_uint_32 extra_bytes.size
        bytes += extra_bytes

        # aggregated
        if aggregated.nil?
          # signatures
          bytes += encode_signatures
        else
          bytes += encode_aggregated_signature
        end

        @hash = SHA3::Digest::SHA256.hexdigest bytes.pack('C*')
        @hex = bytes.pack('C*').unpack1('H*')

        self
      end

      def decode
        @bytes = [hex].pack('H*').bytes
        @hash = SHA3::Digest::SHA256.hexdigest @bytes.pack('C*')

        magic = @bytes.shift(2)
        raise ArgumentError, 'Not valid raw' unless magic == MAGIC

        version = @bytes.shift(2)
        @version = MixinBot::Utils.bytes_to_int version

        asset = @bytes.shift(32)
        @asset = asset.pack('C*').unpack1('H*')

        # read inputs
        decode_inputs

        # read outputs
        decode_outputs

        # TODO:
        # read references
        references_size = @bytes.shift 2
        raise ArgumentError, 'Not support references yet' unless references_size == NULL_BYTES

        # read extra
        # unsigned 32 endian for extra size
        extra_size = MixinBot::Utils.decode_uint_32 @bytes.shift(4)
        @extra = @bytes.shift(extra_size).pack('C*')

        num = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
        if num == MAX_ENCODE_INT
          # aggregated
          @aggregated = {}

          raise ArgumentError, 'invalid aggregated' unless MixinBot::Utils.decode_uint_16(@bytes.shift(2)) == AGGREGATED_SIGNATURE_PREFIX

          @aggregated['signature'] = @bytes.shift(64).pack('C*').unpack1('H*')

          byte = @bytes.shift
          case byte
          when AGGREGATED_SIGNATURE_ORDINAY_MASK.first
            @aggregated['signers'] = []
            masks_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
            masks = @bytes.shift(masks_size)
            masks = [masks] unless masks.is_a? Array

            masks.each_with_index do |mask, i|
              8.times do |j|
                k = 1 << j
                aggregated['signers'].push(i * 8 + j) if mask & k == k
              end
            end
          when AGGREGATED_SIGNATURE_SPARSE_MASK.first
            signers_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
            return if signers_size == 0

            aggregated['signers'] = []
            signers_size.times do
              aggregated['signers'].push MixinBot::Utils.decode_uint_16(@bytes.shift(2))
            end
          end
        elsif num.present? && num > 0 && @bytes.size > 0
          @signatures = []
          num.times do
            signature = {}

            keys_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)

            keys_size.times do
              index = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
              signature[index] = @bytes.shift(64).pack('C*').unpack1('H*')
            end

            @signatures << signature
          end
        end

        self
      end

      def to_h
        {
          version: version,
          asset: asset,
          inputs: inputs,
          outputs: outputs,
          extra: extra,
          signatures: signatures,
          aggregated: aggregated,
          hash: hash,
          references: references
        }.compact
      end

      private

      def encode_inputs
        bytes = []

        bytes += MixinBot::Utils.encode_uint_16(inputs.size)

        inputs.each do |input|
          bytes += [input['hash']].pack('H*').bytes
          bytes += MixinBot::Utils.encode_uint_16(input['index'])

          # genesis
          genesis = input['genesis'] || ''
          if genesis.empty?
            bytes += NULL_BYTES
          else
            genesis_bytes = [genesis].pack('H*').bytes
            bytes += MixinBot::Utils.encode_uint_16 genesis_bytes.size
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
            bytes += MixinBot::Utils.encode_uint_16 asset_bytes.size
            bytes += asset_bytes

            transaction_bytes = [deposit['transaction']].pack('H*')
            bytes += MixinBot::Utils.encode_uint_16 transaction_bytes.size
            bytes += transaction_bytes

            bytes += MixinBot::Utils.encode_uint_64 deposit['index']

            amount_bytes = MixinBot::Utils.bytes_of deposit['amount']
            bytes +=  MixinBot::Utils.encode_uint_16 amount_bytes.size
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
              bytes += MixinBot::Utils.encode_uint_16 NULL_BYTES
            else
              group_bytes = [group].pack('H*')
              bytes += MixinBot::Utils.encode_uint_16 group_bytes.size
              bytes += group_bytes
            end

            bytes += MixinBot::Utils.encode_uint_64 mint['batch']

            amount_bytes = MixinBot::Utils.int_to_bytes mint['amount']
            bytes +=  MixinBot::Utils.encode_uint_16 amount_bytes.size
            bytes +=  amount_bytes
          end
        end

        bytes
      end

      def encode_outputs
        bytes = []

        bytes += MixinBot::Utils.encode_uint_16 outputs.size

        outputs.each do |output|
          type = output['type'] || 0
          bytes += [0x00, type]

          # amount
          amount_bytes = MixinBot::Utils.int_to_bytes (output['amount'].to_d * 1e8).round
          bytes +=  MixinBot::Utils.encode_uint_16 amount_bytes.size
          bytes +=  amount_bytes

          # keys
          bytes +=  MixinBot::Utils.encode_uint_16 output['keys'].size
          output['keys'].each do |key|
            bytes += [key].pack('H*').bytes
          end

          # mask
          bytes += [output['mask']].pack('H*').bytes

          # script
          script_bytes = [output['script']].pack('H*').bytes
          bytes += MixinBot::Utils.encode_uint_16 script_bytes.size
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
            @asset_bytes = [withdrawal['asset']].pack('H*')
            bytes += MixinBot::Utils.encode_uint_16 asset_bytes.size
            bytes += asset_bytes

            # address
            address = withdrawal['address'] || ''
            if address.empty?
              bytes += NULL_BYTES
            else
              address_bytes = [address].pack('H*').bytes
              bytes += MixinBot::Utils.encode_uint_16 address.size
              bytes += address_bytes
            end

            # tag
            tag = withdrawal['tag'] || ''
            if tag.empty?
              bytes += NULL_BYTES
            else
              address_bytes = [tag].pack('H*').bytes
              bytes += MixinBot::Utils.encode_uint_16 tag.size
              bytes += address_bytes
            end
          end
        end

        bytes
      end

      def encode_aggregated_signature
        bytes = []

        bytes += MixinBot::Utils.encode_uint_16 MAX_ENCODE_INT
        bytes += MixinBot::Utils.encode_uint_16 AGGREGATED_SIGNATURE_PREFIX
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
            bytes += MixinBot::Utils.encode_uint_16 aggregated['signers'].size
            signers.map(&->(signer) { bytes += MixinBot::Utils.encode_uint_16(signer) })
          end

          masks_bytes = Array.new(max / 8 + 1, 0)
          signers.each do |signer|
            masks[signer/8] = masks[signer/8] ^ (1 << (signer % 8))
          end
          bytes += AGGREGATED_SIGNATURE_ORDINAY_MASK
          bytes += MixinBot::Utils.encode_uint_16 masks_bytes.size
          bytes += masks_bytes
        end

        bytes
      end

      def encode_signatures
        bytes = []

        sl =
          if signatures.is_a? Array
            signatures.size
          else
            0
          end

        raise ArgumentError, 'signatures overflow' if sl == MAX_ENCODE_INT
        bytes += MixinBot::Utils.encode_uint_16 sl

        if sl > 0
          signatures.each do |signature|
            bytes += MixinBot::Utils.encode_uint_16 signature.keys.size

            signature.keys.sort.each do |key|
              signature_bytes = [signature[key]].pack('H*').bytes
              bytes += MixinBot::Utils.encode_uint_16 key
              bytes += signature_bytes
            end
          end
        end

        bytes
      end

      def decode_inputs
        inputs_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
        @inputs = []
        inputs_size.times do
          input = {}
          hash = @bytes.shift(32)
          input['hash'] = hash.pack('C*').unpack1('H*')

          index = @bytes.shift(2)
          input['index'] = MixinBot::Utils.decode_uint_16 index

          if @bytes[...2] != NULL_BYTES
            genesis_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
            genesis = @bytes.shift genesis_size
            input['genesis'] = genesis.pack('C*').unpack1('H*')
          else
            @bytes.shift 2
          end

          if @bytes[...2] != NULL_BYTES
            magic = @bytes.shift(2)
            raise ArgumentError, 'Not valid input' unless magic == MAGIC

            deposit = {}
            deposit['chain'] = @bytes.shift(32).pack('C*').unpack1('H*')

            asset_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
            deposit['asset'] = @bytes.shift(asset_size).unpack1('H*')

            transaction_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
            deposit['transaction'] = @bytes.shift(transaction_size).unpack1('H*')

            deposit['index'] = MixinBot::Utils.decode_uint_64 @bytes.shift(8)

            amount_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
            deposit['amount'] = MixinBot::Utils.bytes_to_int @bytes.shift(amount_size)

            input['deposit'] = deposit
          else
            @bytes.shift 2
          end

          if @bytes[...2] != NULL_BYTES
            magic = @bytes.shift(2)
            raise ArgumentError, 'Not valid input' unless magic == MAGIC

            mint = {}
            if bytes[...2] != NULL_BYTES
              group_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
              mint['group'] = @bytes.shift(group_size).unpack1('H*')
            else
              @bytes.shift 2
            end

            mint['batch'] = MixinBot::Utils.decode_uint_64 @bytes.shift(8)
            _amount_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
            mint['amount'] = MixinBot::Utils.bytes_to_int bytes.shift(_amount_size)

            input['mint'] = mint
          else
            @bytes.shift 2
          end

          @inputs.push input
        end

        self
      end

      def decode_outputs
        outputs_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
        @outputs = []
        outputs_size.times do
          output = {}

          @bytes.shift
          type = @bytes.shift
          output['type'] = type

          amount_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
          output['amount'] = format('%.8f', MixinBot::Utils.bytes_to_int(@bytes.shift(amount_size)).to_f / 1e8).gsub(/\.?0+$/, '')

          output['keys'] = []
          keys_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
          keys_size.times do
            output['keys'].push @bytes.shift(32).pack('C*').unpack1('H*')
          end

          output['mask'] = @bytes.shift(32).pack('C*').unpack1('H*')

          script_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
          output['script'] = @bytes.shift(script_size).pack('C*').unpack1('H*')

          if @bytes[...2] != NULL_BYTES
            magic = @bytes.shift(2)
            raise ArgumentError, 'Not valid output' unless magic == MAGIC

            withdraw = {}

            output['chain'] = @bytes.shift(32).pack('C*').unpack1('H*')

            asset_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
            output['asset'] = @bytes.shift(asset_size).unpack1('H*')

            if @bytes[...2] != NULL_BYTES
              address = {}

              adderss_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
              output['adderss'] = @bytes.shift(adderss_size).pack('C*').unpack1('H*')
            else
              @bytes.shift 2
            end

            if @bytes[...2] != NULL_BYTES
              tag = {}

              tag_size = MixinBot::Utils.decode_uint_16 @bytes.shift(2)
              output['tag'] = @bytes.shift(tag_size).pack('C*').unpack1('H*')
            else
              @bytes.shift 2
            end
          else
            @bytes.shift 2
          end

          @outputs.push output
        end

        self
      end
    end
  end
end
