# frozen_string_literal: true

module MixinBot
  module Utils
    module Address
      MAIN_ADDRESS_PREFIX = 'XIN'
      MIX_ADDRESS_PREFIX = 'MIX'
      MIX_ADDRESS_VERSION = 2

      def build_main_address(public_key)
        msg = MAIN_ADDRESS_PREFIX + public_key
        checksum = SHA3::Digest::SHA256.digest msg
        data = public_key + checksum[0...4]
        base58 = Base58.binary_to_base58 data, :bitcoin
        "#{MAIN_ADDRESS_PREFIX}#{base58}"
      end

      def parse_main_address(address)
        raise ArgumentError, 'invalid address' unless address.start_with? MAIN_ADDRESS_PREFIX

        data = address[MAIN_ADDRESS_PREFIX.length..]
        data = Base58.base58_to_binary data, :bitcoin
        raise ArgumentError, 'invalid address' unless data.length == 68

        payload = data[...-4]

        msg = MAIN_ADDRESS_PREFIX + payload
        checksum = SHA3::Digest::SHA256.digest msg

        raise ArgumentError, 'invalid address' unless checksum[0...4] == data[-4..]

        payload
      end

      def build_mix_address(members, threshold)
        raise ArgumentError, 'members should be an array' unless members.is_a? Array
        raise ArgumentError, 'members should not be empty' if members.empty?
        raise ArgumentError, 'members length should less than 256' if members.length > 255
        raise ArgumentError, "invalid threshold: #{threshold}" if threshold > members.length

        prefix = [MIX_ADDRESS_VERSION].pack('C*') + [threshold].pack('C*') + [members.length].pack('C*')

        msg =
          if members.all?(&->(member) { member.start_with? MAIN_ADDRESS_PREFIX })
            members.map(&->(member) { parse_main_address(member) }).join
          elsif members.none?(&->(member) { member.start_with? MAIN_ADDRESS_PREFIX })
            members.map(&->(member) { MixinBot::UUID.new(hex: member).packed }).join
          else
            raise ArgumentError, 'invalid members'
          end

        checksum = SHA3::Digest::SHA256.digest(MIX_ADDRESS_PREFIX + prefix + msg)

        data = prefix + msg + checksum[0...4]
        data = Base58.binary_to_base58 data, :bitcoin
        "#{MIX_ADDRESS_PREFIX}#{data}"
      end

      def parse_mix_address(address)
        raise ArgumentError, 'invalid address' unless address.start_with? MIX_ADDRESS_PREFIX

        data = address[MIX_ADDRESS_PREFIX.length..]
        data = Base58.base58_to_binary data, :bitcoin
        raise ArgumentError, 'invalid address' if data.length < 3 + 16 + 4

        msg = data[...-4]
        checksum = SHA3::Digest::SHA256.digest((MIX_ADDRESS_PREFIX + msg))[0...4]

        raise ArgumentError, 'invalid address' unless checksum[0...4] == data[-4..]

        version = data[0].ord
        raise ArgumentError, 'invalid address' unless version == MIX_ADDRESS_VERSION

        threshold = data[1].ord
        members_count = data[2].ord

        if data[3..].length == members_count * 16
          members = data[3..].scan(/.{16}/)
          members = members.map(&->(member) { MixinBot::UUID.new(raw: member).unpacked })
        else
          members = data[3..].scan(/.{64}/)
          members = members.map(&->(member) { build_main_address(member) })
        end

        {
          members:,
          threshold:
        }
      end

      def build_safe_recipient(**kwargs)
        members = kwargs[:members]
        threshold = kwargs[:threshold]
        amount = kwargs[:amount]

        members = [members] if members.is_a? String
        amount = format('%.8f', amount.to_d.to_r).gsub(/\.?0+$/, '')

        {
          members:,
          threshold:,
          amount:,
          mix_address: build_mix_address(members, threshold)
        }
      end
    end
  end
end
