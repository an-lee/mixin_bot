require 'active_support/all'
require 'http'
require 'base64'
require 'openssl'
require 'jwt'
require 'jose'
require_relative './mixin_bot/api'

module MixinBot
  class<< self
    attr_accessor :client_id, :client_secret, :session_id, :pin_token, :private_key, :scope
  end

  def self.api
    @api ||= MixinBot::API.new(options={})
  end
end
