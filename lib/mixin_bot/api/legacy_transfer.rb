# frozen_string_literal: true

module MixinBot
  class API
    module LegacyTransfer
      TRANSFER_ARGUMENTS = %i[asset_id opponent_id amount].freeze
      def create_transfer(pin, **kwargs)
        raise ArgumentError, "#{TRANSFER_ARGUMENTS.join(', ')} are needed for create transfer" unless TRANSFER_ARGUMENTS.all? { |param| kwargs.keys.include? param }

        asset_id = kwargs[:asset_id]
        opponent_id = kwargs[:opponent_id]
        amount = format('%.8f', kwargs[:amount].to_d.to_r).gsub(/\.?0+$/, '')
        trace_id = kwargs[:trace_id] || SecureRandom.uuid
        memo = kwargs[:memo] || ''

        payload = {
          asset_id:,
          opponent_id:,
          amount:,
          trace_id:,
          memo:
        }

        if pin.length > 6
          pin_base64 = encrypt_tip_pin pin, 'TIP:TRANSFER:CREATE:', asset_id, opponent_id, amount, trace_id, memo
          payload[:pin_base64] = pin_base64
        else
          encrypted_pin = encrypt_pin pin
          payload[:pin] = encrypted_pin
        end

        path = '/transfers'
        client.post path, **payload
      end

      def transfer(trace_id, access_token: nil)
        path = format('/transfers/trace/%<trace_id>s', trace_id:)
        client.get path, access_token:
      end
      alias read_transfer transfer
    end
  end
end
