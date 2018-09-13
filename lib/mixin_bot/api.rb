require_relative './client'
require_relative './errors'
require_relative './api/auth'
require_relative './api/me'
require_relative './api/payment'
require_relative './api/pin'
require_relative './api/transfer'
require_relative './api/user'

module MixinBot
  class API
    attr_reader :client_id, :client_secret, :session_id, :pin_token, :private_key, :scope
    attr_reader :client

    def initialize(options={})
      @client_id = options[:client_id]  || MixinBot.client_id
      @client_secret = options[:client_secret] || MixinBot.client_secret
      @session_id = options[:session_id] || MixinBot.session_id
      @pin_token = Base64.decode64 options[:pin_token] || MixinBot.pin_token
      @private_key = OpenSSL::PKey::RSA.new options[:private_key] || MixinBot.private_key
      @scope = options[:scope] || MixinBot.scope || 'PROFILE:READ+PHONE:READ+ASSETS:READ'
      @client = Client.new
    end

    include MixinBot::API::Auth
    include MixinBot::API::Me
    include MixinBot::API::Payment
    include MixinBot::API::Pin
    include MixinBot::API::Transfer
    include MixinBot::API::User
  end
end
