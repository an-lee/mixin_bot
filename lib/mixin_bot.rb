# frozen_string_literal: true

# third-party dependencies
require 'English'
require 'active_support/core_ext/hash'
require 'base64'
require 'digest'
require 'faye/websocket'
require 'http'
require 'jose'
require 'msgpack'
require 'open3'
require 'openssl'
require 'rbnacl'
require 'sha3'

require_relative './mixin_bot/api'
require_relative './mixin_bot/cli'
require_relative './mixin_bot/utils'
require_relative './mixin_bot/version'

module MixinBot
  class<< self
    attr_accessor :client_id, :client_secret, :session_id, :pin_token, :private_key, :scope, :api_host, :blaze_host
  end

  def self.api
    @api ||= MixinBot::API.new
  end

  class HttpError < StandardError; end
  class RequestError < StandardError; end
  class ResponseError < StandardError; end
  class UnauthorizedError < StandardError; end
  class ForbiddenError < StandardError; end
  class InsufficientBalanceError < StandardError; end
  class InsufficientPoolError < StandardError; end
  class PinError < StandardError; end
end
