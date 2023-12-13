# frozen_string_literal: true

module MixinBot
  class API
    module Withdraw
      # https://developers.mixin.one/api/alpha-mixin-network/create-address/
      def create_withdraw_address(options, access_token: nil)
        path = '/addresses'
        pin = options[:pin]
        payload =
          {
            asset_id: options[:asset_id],
            destination: options[:destination],
            tag: options[:tag],
            label: options[:label],
          }
        
        if pin.length > 6
          payload[:pin_base64] = encrypt_tip_pin pin, 'TIP:ADDRESS:ADD:', payload[:asset_id], payload[:destination], payload[:tag], payload[:label]
        else
          payload[:pin] = encrypt_pin pin
        end

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # https://developers.mixin.one/api/alpha-mixin-network/read-address/
      def get_withdraw_address(address, access_token: nil)
        path = format('/addresses/%<address>s', address: address)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      # https://developers.mixin.one/api/alpha-mixin-network/delete-address/
      def delete_withdraw_address(address, pin, access_token: nil)
        path = format('/addresses/%<address>s/delete', address: address)
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

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # https://developers.mixin.one/api/alpha-mixin-network/withdrawal-addresses/
      def withdrawals(options, access_token: nil)
        address_id = options[:address_id]
        pin = options[:pin]
        amount = format('%.8f', options[:amount].to_d.to_r)
        trace_id = options[:trace_id]
        memo = options[:memo]

        path = '/withdrawals'
        payload = {
          address_id: address_id,
          amount: amount,
          trace_id: trace_id,
          memo: memo,
        }

        if pin.length > 6
          fee = '0'
          payload[:pin_base64] = encrypt_tip_pin pin, 'TIP:WITHDRAW:', address_id, amount, fee, trace_id, memo
        else
          payload[:pin] = encrypt_pin pin
        end

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end
    end
  end
end
