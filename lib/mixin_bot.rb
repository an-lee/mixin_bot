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
require 'faraday'
require 'faraday/multipart'
require 'faraday/retry'
require 'jose'
require 'msgpack'
require 'open3'
require 'openssl'
require 'rbnacl'
require 'sha3'

require_relative 'mixin_bot/address'
require_relative 'mixin_bot/api'
require_relative 'mixin_bot/cli'
require_relative 'mixin_bot/invoice'
require_relative 'mixin_bot/utils'
require_relative 'mixin_bot/nfo'
require_relative 'mixin_bot/uuid'
require_relative 'mixin_bot/transaction'
require_relative 'mixin_bot/version'
require_relative 'mvm'

##
# MixinBot
#
# Entry point for the Mixin Ruby SDK. It exposes a global configuration,
# an API facade, and utility helpers.
#
# Typical usage:
#
#   MixinBot.configure do
#     self.app_id = '...'
#     self.session_id = '...'
#     self.session_private_key = '...'
#     self.server_public_key = '...'
#   end
#
#   api = MixinBot.api
#   me = api.read_me
#
# See `MixinBot::API` for the available endpoints and `MixinBot::Configuration`
# for configurable attributes.
#
module MixinBot
  class << self
    # Returns a memoized instance of `MixinBot::API` with the current
    # configuration.
    def api
      return @api if defined?(@api)

      @api = MixinBot::API.new
      @api
    end

    # Returns a memoized global `MixinBot::Configuration` instance. You can
    # modify it via {#configure}.
    def config
      return @config if defined?(@config)

      @config = MixinBot::Configuration.new
      @config
    end

    # Yields the global configuration object for convenient setup.
    #
    # Example:
    #   MixinBot.configure do
    #     self.app_id = '...'
    #   end
    def configure(&)
      config.instance_exec(&)
    end

    # Returns the `MixinBot::Utils` module with helper methods for crypto,
    # encoding, addresses, etc.
    def utils
      MixinBot::Utils
    end
  end

  # Base error class for all SDK-specific errors.
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
  class InvalidInvoiceFormatError < Error; end
end
