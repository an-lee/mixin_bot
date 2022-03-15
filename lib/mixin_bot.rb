# frozen_string_literal: true

# third-party dependencies
require 'English'
require 'active_support/all'
require 'base64'
require 'bigdecimal'
require 'bigdecimal/util'
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

  class Error < StandardError; end
  class ArgumentError < StandardError; end
  class HttpError < Error; end
  class RequestError < Error; end
  class ResponseError < Error; end
  class NotFoundError < Error; end
  class UnauthorizedError < Error; end
  class ForbiddenError < Error; end
  class InsufficientBalanceError < Error; end
  class InsufficientPoolError < Error; end
  class PinError < Error; end
  class InvalidNfoFormatError < MixinBot::Error; end
  class InvalidUuidFormatError < MixinBot::Error; end
  class InvalidTransactionFormatError < MixinBot::Error; end
end
