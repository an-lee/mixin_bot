# frozen_string_literal: true

module MixinBot
  class API
    module Safe
      def safe_profile(**options)
        path = '/safe/me'
        access_token = options[:access_token] || access_token('GET', path)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
    end
  end
end
