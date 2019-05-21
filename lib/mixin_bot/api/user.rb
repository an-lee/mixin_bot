module MixinBot
  class API
    module User
      def read_user(user_id, access_token=nil)
        # user_id: Mixin User Id
        path = format('/users/%s', user_id)
        access_token ||= self.access_token('GET', path, '')
        authorization = format('Bearer %s', access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def create_user(full_name, session_secret)
        payload = {
          session_secret: session_secret,
          full_name:full_name
        }
        access_token = self.access_token('POST', "/users", payload.to_json)
        authorization = format('Bearer %s', access_token)
        client.post("/users", headers: { 'Authorization': authorization }, json: payload)
      end

      def search_user(q, access_token=nil)
        # q: Mixin Id or Phone Number
        path = format('/search/%s', q)
        access_token ||= self.access_token('GET', path, '')
        authorization = format('Bearer %s', access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def fetch_users(user_ids, access_token=nil)
        # user_ids: a array of user_ids
        path = '/users/fetch'
        user_ids = [user_ids] if user_ids.is_a? String
        payload = user_ids
        access_token ||= self.access_token('POST', path, payload.to_json)
        authorization = format('Bearer %s', access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def create_withdraw_address(asset_id,pin,public_key,account_name,account_tag,label)
        path = '/addresses'
        enPin = encrypt_pin(pin)
        if public_key == ""
          payload = {
            asset_id: asset_id,
            account_name: account_name,
            account_tag: account_tag,
            label: label,
            pin: enPin
          }
        else
          payload = {
            asset_id: asset_id,
            public_key: public_key,
            label: label,
            pin: enPin
          }
        end
        access_token ||= self.access_token('POST', path, payload.to_json)
        authorization = format('Bearer %s', access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def get_withdraw_address(address)
        path = '/addresses/' + address
        access_token = self.access_token('GET', path, '')
        authorization = format('Bearer %s', access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
    end
  end
end
