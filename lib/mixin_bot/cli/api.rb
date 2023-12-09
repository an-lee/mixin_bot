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

    desc 'authcode', 'code to authorize other mixin account'
    option :keystore, type: :string, aliases: '-k', required: true, desc: 'keystore or keystore.json file path'
    option :client_id, type: :string, required: true, aliases: '-c', desc: 'client_id of bot to authorize'
    option :scope, type: :array, default: ['PROFILE:READ'], aliases: '-s', desc: 'scope to authorize'
    def authcode
      res = {}
      CLI::UI::Spinner.spin('POST /oauth/authorize') do |_spinner|
        res =
          api_instance.authorize_code(
            user_id: options[:client_id],
            scope: options[:scope],
            pin: keystore['pin']
          )
      end
      log res['data']
    end

    desc 'updatetip PIN', 'update TIP pin'
    option :keystore, type: :string, aliases: '-k', required: true, desc: 'keystore or keystore.json file path'
    def updatetip(pin)
      profile = api_instance.me
      log UI.fmt "{{v}} #{profile['full_name']}, TIP counter: #{profile['tip_counter']}"

      counter = profile['tip_counter']
      key = api_instance.prepare_tip_pin counter
      log UI.fmt "{{v}} Generated key: #{key[:private_key]}"

      res = api_instance.update_pin old_pin: pin.to_s, pin: key[:public_key]

      log({
        pin: key[:private_key],
        tip_key_base64: res['tip_key_base64']
      })
    rescue StandardError => e
      log UI.fmt "{{x}} #{e.inspect}"
    end

    desc 'verify PIN', 'verify pin'
    option :keystore, type: :string, aliases: '-k', required: true, desc: 'keystore or keystore.json file path'
    def verifypin(pin)
      res = api_instance.verify_pin pin.to_s

      log res
    rescue StandardError => e
      log UI.fmt "{{x}} #{e.inspect}"
    end

    desc 'transfer USER_ID', 'transfer asset to USER_ID'
    option :asset, type: :string, required: true, desc: 'Asset ID'
    option :amount, type: :numeric, required: true, desc: 'Amount'
    option :keystore, type: :string, aliases: '-k', required: true, desc: 'keystore or keystore.json file path'
    def transfer(user_id)
      CLI::UI::Spinner.spin "Transfer #{options[:amount]} #{options[:asset]} to #{user_id}" do |_spinner|
        api_instance.create_transfer(
          keystore['pin'],
          {
            asset_id: options[:asset],
            opponent_id: user_id,
            amount: options[:amount],
            memo: 'transfer'
          }
        )
      end
    end

    desc 'saferegister', 'register SAFE network'
    option :keystore, type: :string, aliases: '-k', required: true, desc: 'keystore or keystore.json file path'
    def saferegister
      res = api_instance.safe_register keystore['pin']
      log res
    end
  end
end
