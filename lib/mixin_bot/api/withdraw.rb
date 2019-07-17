# frozen_string_literal: true

module MixinBot
  class API
    module Withdraw
      # https://developers.mixin.one/api/alpha-mixin-network/create-address/
      def create_withdraw_address(options)
        path = '/addresses'
        encrypted_pin = encrypt_pin(options[:pin])
        payload = 
          # for EOS withdraw, account_name & account_tag must be valid
          if options[:public_key].nil?
            {
              asset_id: options[:asset_id],
              account_name: options[:account_name],
              account_tag: options[:account_tag],
              label: options[:label],
              pin: encrypted_pin
            }
          # for other withdraw
          else
            {
              asset_id: options[:asset_id],
              public_key: options[:public_key],
              label: options[:label],
              pin: encrypted_pin
            }
          end

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # https://developers.mixin.one/api/alpha-mixin-network/read-address/
      def get_withdraw_address(address)
        path = format('/addresses/%<address>s', address: address)
        access_token = access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      # https://developers.mixin.one/api/alpha-mixin-network/delete-address/
      def delete_withdraw_address(address, pin)
        path = format('/addresses/%<address>s/delete', address: address)
        payload = {
          pin: encrypt_pin(pin)
        }

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # https://developers.mixin.one/api/alpha-mixin-network/withdrawal-addresses/
      def withdrawals(options)
        address_id = options[:address_id]
        pin = options[:pin]
        amount = options[:amount]
        trace_id = options[:trace_id]
        memo = options[:memo]

        path = '/withdrawals'
        payload = {
          address_id: address_id,
          amount: amount,
          trace_id: trace_id,
          memo: memo,
          pin: encrypt_pin(pin)
        }

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end
    end
  end
end