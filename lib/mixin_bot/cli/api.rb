# frozen_string_literal: true

module MixinBot
  class CLI < Thor
    desc 'api', 'request Mixin API'
    option :keystore, type: :string, aliases: '-k', required: true, default: '~/.mixinbot/keystore.json', desc: 'Specify keystore.json file path'
    option :url, type: :string, aliases: '-u', required: true, desc: 'Mixin API url, exmaple: /me'
    option :method, type: :string, aliases: '-m', default: 'GET', desc: 'GET or POST'
    option :params, type: :hash, aliases: '-p', desc: 'Example: --params=limit:100 state:unspent'
    option :body, type: :hash, aliases: '-b', default: {}, desc: 'Example: --body=pin:123456'
    option :accesstoken, type: :string, aliases: '-a', desc: 'Specify a accesstoken, or will generate by keystore'
    def api
      url = options[:url]
      url = "#{url}?#{URI.encode_www_form(options[:params])}" if options[:params].present?
      payload =
        if options[:body].blank?
          ''
        else
          options[:body].to_json
        end

      access_token = options[:accesstoken] || api_instance.access_token(options[:method].upcase, url, payload)
      authorization = format('Bearer %<access_token>s', access_token: access_token)
      res = ''

      CLI::UI::Spinner.spin("#{options[:method]} #{url}, payload: #{payload}") do |_spinner|
        res =
          case options[:method].downcase.to_sym
          when :post
            api_instance.client.post(url, headers: { 'Authorization': authorization }, json: options[:body])
          when :get
            api_instance.client.get(url, headers: { 'Authorization': authorization })
          end
      end

      log res['data']
    end
  end
end
