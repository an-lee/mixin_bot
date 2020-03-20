# frozen_string_literal: true

require 'http'
require 'base64'
require 'faye/websocket'
require 'ffi'
require 'openssl'
require 'jwt'
require 'jose'
require 'schmooze'
require 'msgpack'
require 'digest'
require_relative './mixin_bot/api'
require_relative './mixin_bot/cli'
require_relative './mixin_bot/version'

module MixinBot
  class<< self
    attr_accessor :client_id, :client_secret, :session_id, :pin_token, :private_key, :scope, :api_host, :blaze_host
  end

  def self.api
    @api ||= MixinBot::API.new
  end

end
