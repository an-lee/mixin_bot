# frozen_string_literal: true

require 'http'
require 'base64'
require 'faye/websocket'
require 'openssl'
require 'jwt'
require 'jose'
require_relative './mixin_bot/api'

module MixinBot
  class<< self
    attr_accessor :client_id, :client_secret, :session_id, :pin_token, :private_key, :scope, :api_host, :blaze_host
  end

  def self.api
    @api ||= MixinBot::API.new
  end
end
