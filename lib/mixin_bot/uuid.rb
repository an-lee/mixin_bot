# frozen_string_literal: true

module MixinBot
  class UUID
    attr_accessor :hex, :raw

    def initialize(**args)
      @hex = args[:hex]
      @raw = args[:raw]

      raise MixinBot::InvalidUuidFormatError if raw.present? && raw.size != 16
      raise MixinBot::InvalidUuidFormatError if hex.present? && hex.gsub('-', '').size != 32
    end

    def packed
      if raw.present?
        raw
      elsif hex.present?
        [hex.gsub('-', '')].pack('H*')
      end
    end

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
