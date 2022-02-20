# frozen_string_literal: true

module MixinBot
  class CLI < Thor
    desc 'api PATH', 'request PATH of Mixin API'
    long_desc <<-LONGDESC
      use `mixinbot api PATH` to request any Mixin API

      Get user infomation:

      $ mixinbot api /me -k ~/.mixinbot/keystore.json

      Search user infomation:

      $ mixinbot api /search/1051445 -k ~/.mixinbot/keystore.json

      Generate a multisig payment:

      $ mixinbot api /payments -k ~/.mixinbot/keystore.json -m POST -d '{"asset_id":"965e5c6e-434c-3fa9-b780-c50f43cd955c", "amount":"1", "trace_id": "37f16abb-0640-4d01-9423-a06121732d35", "memo":"test", "opponent_multisig":{"receivers":["0508a116-1239-4e28-b150-85a8e3e6b400", "7ed9292d-7c95-4333-aa48-a8c640064186", "a67c6e87-1c9e-4a1c-b81c-47a9f4f1bff1"], "threshold":2}}'
    LONGDESC
    option :keystore, type: :string, aliases: '-k', required: true, desc: 'keystore or keystore.json file path'
    option :method, type: :string, aliases: '-m', default: 'GET', desc: 'HTTP method, GET or POST'
    option :params, type: :hash, aliases: '-p', desc: 'HTTP GET params'
    option :data, type: :string, aliases: '-d', default: '{}', desc: 'HTTP POST data'
    option :accesstoken, type: :string, aliases: '-t', desc: 'Specify a accesstoken, or will generate by keystore'
    def api(path)
      path = "#{path}?#{URI.encode_www_form(options[:params])}" if options[:params].present?
      payload =
        begin
          JSON.parse options[:data]
        rescue JSON::ParserError => e
          log UI.fmt("{{x}} #{e.inspect}")
          {}
        end

      access_token = options[:accesstoken] || api_instance.access_token(options[:method].upcase, path, payload.blank? ? '' : payload.to_json)
      authorization = format('Bearer %<access_token>s', access_token: access_token)
      res = {}

      CLI::UI::Spinner.spin("#{options[:method]} #{path}, payload: #{payload}") do |_spinner|
        res =
          case options[:method].downcase.to_sym
          when :post
            api_instance.client.post(path, headers: { 'Authorization': authorization }, json: payload)
          when :get
            api_instance.client.get(path, headers: { 'Authorization': authorization })
          end
      end

      log res['data']
    end
  end
end