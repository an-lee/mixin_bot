# frozen_string_literal: true

module MixinBot
  class API
    module Withdraw
      def create_withdraw_address(**kwargs)
        path = '/addresses'
        pin = kwargs[:pin]
        payload =
          {
            asset_id: kwargs[:asset_id],
            destination: kwargs[:destination],
            tag: kwargs[:tag],
            label: kwargs[:label]
          }

        if pin.length > 6
          payload[:pin_base64] = encrypt_tip_pin pin, 'TIP:ADDRESS:ADD:', payload[:asset_id], payload[:destination], payload[:tag], payload[:label]
        else
          payload[:pin] = encrypt_pin pin
        end

        client.post path, **payload
      end

      def get_withdraw_address(address, access_token: nil)
        path = format('/addresses/%<address>s', address:)

        client.get path, access_token:
      end

      def delete_withdraw_address(address, **kwargs)
        pin = kwargs[:pin]

        path = format('/addresses/%<address>s/delete', address:)
        payload =
          if pin.length > 6
            {
              pin_base64: encrypt_tip_pin(pin, 'TIP:ADDRESS:REMOVE:', address)
            }
          else
            {
              pin: encrypt_pin(pin)
            }
          end

        client.post path, **payload
      end

      def withdrawals(**kwargs)
        address_id = kwargs[:address_id]
        pin = kwargs[:pin]
        amount = format('%.8f', kwargs[:amount].to_d.to_r)
        trace_id = kwargs[:trace_id]
        memo = kwargs[:memo]
        kwargs[:access_token]

        path = '/withdrawals'
        payload = {
          address_id:,
          amount:,
          trace_id:,
          memo:
        }

        if pin.length > 6
          fee = '0'
          payload[:pin_base64] = encrypt_tip_pin pin, 'TIP:WITHDRAW:', address_id, amount, fee, trace_id, memo
        else
          payload[:pin] = encrypt_pin pin
        end

        client.post path, **payload
      end
    end
  end
end
