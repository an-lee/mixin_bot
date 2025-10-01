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
# = MixinBot
#
# MixinBot is a Ruby SDK for interacting with the Mixin Network API.
#
# == Overview
#
# Mixin Network is a free and lightning fast peer-to-peer transactional network
# for digital assets. MixinBot provides a comprehensive Ruby interface to interact
# with the Mixin Network, including asset management, transfers, messaging, and more.
#
# == Installation
#
# Add this line to your application's Gemfile:
#
#   gem 'mixin_bot'
#
# And then execute:
#
#   $ bundle install
#
# Or install it yourself as:
#
#   $ gem install mixin_bot
#
# == Quick Start
#
# === Configuration
#
# Configure your Mixin bot credentials:
#
#   MixinBot.configure do
#     app_id = '25696f85-b7b4-4509-8c3f-2684a8fc4a2a'
#     client_secret = 'd9dc58107bacde671...'
#     session_id = '25696f85-b7b4-4509-8c3f-2684a8fc4a2a'
#     server_public_key = 'b0pjBUKI0Vp9K+NspaL....'
#     session_private_key = '...'
#   end
#
# === Basic Usage
#
# Get bot profile:
#
#   MixinBot.api.me
#   # => { "user_id" => "...", "full_name" => "...", ... }
#
# Get bot assets:
#
#   MixinBot.api.assets
#   # => [{ "asset_id" => "...", "symbol" => "BTC", ... }, ...]
#
# Transfer assets:
#
#   MixinBot.api.create_transfer(
#     '123456',                                              # pin_code
#     asset_id: '965e5c6e-434c-3fa9-b780-c50f43cd955c',     # CNB
#     opponent_id: '6ae1c7ae-1df1-498e-8f21-d48cb6d129b5',  # receiver
#     amount: 0.00000001,
#     memo: 'test transfer',
#     trace_id: SecureRandom.uuid
#   )
#
# === Managing Multiple Bots
#
# You can manage multiple bots by creating separate API instances:
#
#   bot1 = MixinBot::API.new(
#     app_id: '...',
#     session_id: '...',
#     session_private_key: '...',
#     server_public_key: '...'
#   )
#
#   bot2 = MixinBot::API.new(
#     app_id: '...',
#     session_id: '...',
#     session_private_key: '...',
#     server_public_key: '...'
#   )
#
#   bot1.me
#   bot2.me
#
# == Main Components
#
# [MixinBot::API] Main API interface for interacting with Mixin Network
# [MixinBot::Configuration] Configuration management for bot credentials
# [MixinBot::Client] HTTP client for making API requests
# [MixinBot::Utils] Utility methods for cryptography and encoding
# [MixinBot::Transaction] Transaction encoding and decoding
# [MixinBot::MixAddress] Address handling for Mixin Network
# [MixinBot::Invoice] Invoice creation and parsing
# [MixinBot::Nfo] NFT memo handling
# [MixinBot::UUID] UUID utilities for Mixin Network
# [MVM] Mixin Virtual Machine integration
#
# == Error Handling
#
# MixinBot defines several custom error classes for different scenarios:
#
#   begin
#     MixinBot.api.create_transfer(...)
#   rescue MixinBot::InsufficientBalanceError => e
#     puts "Insufficient balance: #{e.message}"
#   rescue MixinBot::UnauthorizedError => e
#     puts "Unauthorized: #{e.message}"
#   rescue MixinBot::ResponseError => e
#     puts "API error: #{e.message}"
#   end
#
# == Links
#
# - {Mixin Network Documentation}[https://developers.mixin.one/docs]
# - {GitHub Repository}[https://github.com/an-lee/mixin_bot]
#
module MixinBot
  class << self
    ##
    # Returns the default API instance using the global configuration.
    #
    # This is a singleton instance that will be created on first access.
    # The API instance provides access to all Mixin Network API endpoints.
    #
    #   MixinBot.api.me
    #   # => { "user_id" => "...", "full_name" => "..." }
    #
    # @return [MixinBot::API] the default API instance
    #
    def api
      return @api if defined?(@api)

      @api = MixinBot::API.new
      @api
    end

    ##
    # Returns the global configuration instance.
    #
    # The configuration instance stores bot credentials and settings.
    # It will be created on first access with default values.
    #
    # @return [MixinBot::Configuration] the configuration instance
    #
    def config
      return @config if defined?(@config)

      @config = MixinBot::Configuration.new
      @config
    end

    ##
    # Configures the global MixinBot settings.
    #
    # This method yields the configuration instance to a block where
    # you can set your bot credentials and other settings.
    #
    #   MixinBot.configure do
    #     app_id = '25696f85-b7b4-4509-8c3f-2684a8fc4a2a'
    #     session_id = '25696f85-b7b4-4509-8c3f-2684a8fc4a2a'
    #     session_private_key = '...'
    #     server_public_key = '...'
    #   end
    #
    # @yield [Configuration] the configuration instance
    # @return [void]
    #
    def configure(&)
      config.instance_exec(&)
    end

    ##
    # Returns the Utils module for accessing utility methods.
    #
    #   MixinBot.utils.unique_uuid(uuid1, uuid2)
    #
    # @return [Module] the Utils module
    #
    def utils
      MixinBot::Utils
    end
  end

  ##
  # Base error class for all MixinBot errors.
  #
  class Error < StandardError; end

  ##
  # Raised when invalid arguments are provided.
  #
  class ArgumentError < StandardError; end

  ##
  # Raised when HTTP request fails.
  #
  class HttpError < Error; end

  ##
  # Raised when a request to Mixin API fails.
  #
  class RequestError < Error; end

  ##
  # Raised when Mixin API returns an error response.
  #
  class ResponseError < Error; end

  ##
  # Raised when a requested resource is not found (HTTP 404).
  #
  class NotFoundError < Error; end

  ##
  # Raised when a user is not found (error code 10404).
  #
  class UserNotFoundError < Error; end

  ##
  # Raised when authentication fails (HTTP 401).
  #
  class UnauthorizedError < Error; end

  ##
  # Raised when access is forbidden (HTTP 403).
  #
  class ForbiddenError < Error; end

  ##
  # Raised when there is insufficient balance for a transaction (error code 20117).
  #
  class InsufficientBalanceError < Error; end

  ##
  # Raised when there is insufficient pool for a transaction (error code 30103).
  #
  class InsufficientPoolError < Error; end

  ##
  # Raised when PIN verification fails (error codes 20118, 20119).
  #
  class PinError < Error; end

  ##
  # Raised when NFO memo format is invalid.
  #
  class InvalidNfoFormatError < Error; end

  ##
  # Raised when UUID format is invalid.
  #
  class InvalidUuidFormatError < Error; end

  ##
  # Raised when transaction format is invalid.
  #
  class InvalidTransactionFormatError < Error; end

  ##
  # Raised when configuration is not valid or incomplete.
  #
  class ConfigurationNotValidError < Error; end

  ##
  # Raised when invoice format is invalid.
  #
  class InvalidInvoiceFormatError < Error; end
end
