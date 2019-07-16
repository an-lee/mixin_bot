# frozen_string_literal: true

module MixinBot
  class API
    module User
      def read_user(user_id, access_token = nil)
        # user_id: Mixin User Id
        path = format('/users/%<user_id>s', user_id: user_id)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def create_user(full_name, session_secret)
        payload = {
          session_secret: session_secret,
          full_name: full_name
        }

        access_token = access_token('POST', '/users', payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post('/users', headers: { 'Authorization': authorization }, json: payload)
      end

      def search_user(query, access_token = nil)
        # q: Mixin Id or Phone Number
        path = format('/search/%<query>s', query: query)

        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def fetch_users(user_ids, access_token = nil)
        # user_ids: a array of user_ids
        path = '/users/fetch'
        user_ids = [user_ids] if user_ids.is_a? String
        payload = user_ids

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def create_withdraw_address(options)
        asset_id = options[:asset_id]
        pin = options[:pin]
        public_key = options[:public_key]
        account_name = options[:account_name]
        account_tag = options[:account_tag]
        label = options[:label]

        path = '/addresses'
        enrypted_pin = encrypt_pin(pin)
        payload =
          if public_key.present?
            {
              asset_id: asset_id,
              public_key: public_key,
              label: label,
              pin: enrypted_pin
            }
          else
            {
              asset_id: asset_id,
              account_name: account_name,
              account_tag: account_tag,
              label: label,
              pin: enrypted_pin
            }
          end

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def get_withdraw_address(address)
        path = format('/addresses/%<address>s', address: address)
        access_token = self.access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def del_withdraw_address(address, pin)
        path = format('/addresses/%<address>s/delete', address: address)
        payload = {
          pin: encrypt_pin(pin)
        }

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

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
