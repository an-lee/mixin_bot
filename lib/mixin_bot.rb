# frozen_string_literal: true

require 'English'
require 'base64'
require 'digest'
require 'faye/websocket'
require 'http'
require 'jose'
require 'msgpack'
require 'open3'
require 'openssl'
require 'rbnacl'
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
