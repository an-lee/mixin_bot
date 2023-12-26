# frozen_string_literal: true

# third-party dependencies
require 'English'
require 'active_support/all'
require 'base58'
require 'base64'
require 'bigdecimal'
require 'bigdecimal/util'
require 'digest'
require 'digest/blake3'
require 'faye/websocket'
require 'http'
require 'jose'
require 'msgpack'
require 'open3'
require 'openssl'
require 'rbnacl'
require 'sha3'

require_relative 'mixin_bot/api'
require_relative 'mixin_bot/cli'
require_relative 'mixin_bot/utils'
require_relative 'mixin_bot/version'
require_relative 'mvm'

module MixinBot
  class << self
    def api
      return @api if defined?(@api)

      @api = MixinBot::API.new
      @api
    end

    def config
      return @config if defined?(@config)

      @config = MixinBot::Configuration.new
      @config
    end

    def configure(&)
      config.instance_exec(&)
    end
  end

  class Error < StandardError; end
  class ArgumentError < StandardError; end
  class HttpError < Error; end
  class RequestError < Error; end
  class ResponseError < Error; end
  class NotFoundError < Error; end
  class UserNotFoundError < Error; end
  class UnauthorizedError < Error; end
  class ForbiddenError < Error; end
  class InsufficientBalanceError < Error; end
  class InsufficientPoolError < Error; end
  class PinError < Error; end
  class InvalidNfoFormatError < Error; end
  class InvalidUuidFormatError < Error; end
  class InvalidTransactionFormatError < Error; end
  class ConfigurationNotValidError < Error; end
end
