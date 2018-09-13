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
    end
  end
end
