# frozen_string_literal: true

module MixinBot
  ##
  # Utility class for handling Mixin Network UUID format conversions.
  #
  # Mixin Network uses UUIDs extensively for identifying:
  # - Users and bots
  # - Assets
  # - Transactions and traces
  # - Conversations
  #
  # == Format Conversions
  #
  # This class handles conversions between:
  # - Standard UUID format: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" (36 chars)
  # - Packed binary format: 16 bytes
  # - Hex format without dashes: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" (32 chars)
  #
  # == Usage
  #
  #   # From hex format to UUID
  #   uuid = MixinBot::UUID.new(hex: '965e5c6e434c3fa9b780c50f43cd955c')
  #   uuid.unpacked
  #   # => "965e5c6e-434c-3fa9-b780-c50f43cd955c"
  #
  #   # From UUID to packed binary
  #   uuid = MixinBot::UUID.new(hex: '965e5c6e-434c-3fa9-b780-c50f43cd955c')
  #   uuid.packed
  #   # => "\x96^\\nC<?\xA9\xB7\x80\xC5\x0FC\xCD\x95\\"
  #
  #   # From packed binary to UUID
  #   uuid = MixinBot::UUID.new(raw: binary_data)
  #   uuid.unpacked
  #   # => "965e5c6e-434c-3fa9-b780-c50f43cd955c"
  #
  class UUID
    ##
    # @return [String] the UUID in hex format (with or without dashes)
    attr_accessor :hex

    ##
    # @return [String] the UUID in packed binary format (16 bytes)
    attr_accessor :raw

    ##
    # Initializes a new UUID instance.
    #
    # Provide either :hex or :raw parameter. The other format can be
    # obtained via #packed or #unpacked methods.
    #
    # @param args [Hash] initialization options
    # @option args [String] :hex the UUID in hex format (with or without dashes)
    # @option args [String] :raw the UUID in packed binary format (16 bytes)
    #
    # @raise [MixinBot::InvalidUuidFormatError] if format is invalid
    #
    # @example From hex
    #   uuid = MixinBot::UUID.new(hex: '965e5c6e-434c-3fa9-b780-c50f43cd955c')
    #
    # @example From raw binary
    #   uuid = MixinBot::UUID.new(raw: binary_string)
    #
    def initialize(**args)
      args = args.with_indifferent_access

      @hex = args[:hex]
      @raw = args[:raw]

      raise MixinBot::InvalidUuidFormatError if raw.present? && raw.size != 16
      raise MixinBot::InvalidUuidFormatError if hex.present? && hex.gsub('-', '').size != 32
    end

    ##
    # Returns the UUID in packed binary format (16 bytes).
    #
    # @return [String] 16-byte binary string
    #
    # @example
    #   uuid = MixinBot::UUID.new(hex: '965e5c6e-434c-3fa9-b780-c50f43cd955c')
    #   uuid.packed
    #   # => 16-byte binary string
    #
    def packed
      if raw.present?
        raw
      elsif hex.present?
        [hex.gsub('-', '')].pack('H*')
      end
    end

    ##
    # Returns the UUID in standard format with dashes.
    #
    # @return [String] UUID in format "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    #
    # @example
    #   uuid = MixinBot::UUID.new(raw: binary_string)
    #   uuid.unpacked
    #   # => "965e5c6e-434c-3fa9-b780-c50f43cd955c"
    #
    def unpacked
      _hex =
        if hex.present?
          hex.gsub('-', '')
        elsif raw.present?
          _hex = raw.unpack1('H*')
        end

      format(
        '%<first>s-%<second>s-%<third>s-%<forth>s-%<fifth>s',
        first: _hex[0..7],
        second: _hex[8..11],
        third: _hex[12..15],
        forth: _hex[16..19],
        fifth: _hex[20..]
      )
    end
  end
end
