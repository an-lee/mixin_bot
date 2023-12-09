# frozen_string_literal: true

require_relative './client'
require_relative './api/app'
require_relative './api/asset'
require_relative './api/attachment'
require_relative './api/auth'
require_relative './api/blaze'
require_relative './api/collectible'
require_relative './api/conversation'
require_relative './api/encrypted_message'
require_relative './api/me'
require_relative './api/message'
require_relative './api/multisig'
require_relative './api/payment'
require_relative './api/pin'
require_relative './api/rpc'
require_relative './api/safe'
require_relative './api/snapshot'
require_relative './api/tip'
require_relative './api/transaction'
require_relative './api/transfer'
require_relative './api/user'
require_relative './api/withdraw'

module MixinBot
  class API
    attr_reader :client_id, :client_secret, :session_id, :pin_token, :private_key, :client, :blaze_host, :key_type

    def initialize(options = {})
      @client_id = options[:client_id] || MixinBot.client_id
      @client_secret = options[:client_secret] || MixinBot.client_secret
      @session_id = options[:session_id] || MixinBot.session_id
      @client = Client.new(MixinBot.api_host || 'api.mixin.one')
      @blaze_host = MixinBot.blaze_host || 'blaze.mixin.one'
      @pin_token =
        begin
          Base64.urlsafe_decode64 options[:pin_token] || MixinBot.pin_token
        rescue StandardError
          ''
        end
      _private_key = options[:private_key] || MixinBot.private_key
      if /^-----BEGIN RSA PRIVATE KEY-----/.match? _private_key
        @private_key = _private_key.gsub('\\r\\n', "\n").gsub("\r\n", "\n")
        @key_type = :rsa
      else
        @private_key = Base64.urlsafe_decode64 _private_key
        @key_type = :ed25519
      end
    end

    def sign_raw_transaction(tx)
      MixinBot::Utils.sign_raw_transaction tx
    end

    def decode_raw_transaction(raw)
      MixinBot::Utils.decode_raw_transaction raw
    end

    # Use a mixin software to implement transaction build
    def sign_raw_transaction_native(json)
      ensure_mixin_command_exist
      command = format("mixin signrawtransaction --raw '%<arg>s'", arg: json)

      output, error = Open3.capture3(command)
      raise error unless error.empty?

      output.chomp
    end

    # Use a mixin software to implement transaction build
    def decode_raw_transaction_native(raw)
      ensure_mixin_command_exist
      command = format("mixin decoderawtransaction --raw '%<arg>s'", arg: raw)

      output, error = Open3.capture3(command)
      raise error unless error.empty?

      JSON.parse output.chomp
    end

    include MixinBot::API::App
    include MixinBot::API::Asset
    include MixinBot::API::Attachment
    include MixinBot::API::Auth
    include MixinBot::API::Blaze
    include MixinBot::API::Collectible
    include MixinBot::API::Conversation
    include MixinBot::API::EncryptedMessage
    include MixinBot::API::Me
    include MixinBot::API::Message
    include MixinBot::API::Multisig
    include MixinBot::API::Payment
    include MixinBot::API::Pin
    include MixinBot::API::Rpc
    include MixinBot::API::Safe
    include MixinBot::API::Snapshot
    include MixinBot::API::Tip
    include MixinBot::API::Transaction
    include MixinBot::API::Transfer
    include MixinBot::API::User
    include MixinBot::API::Withdraw

    private

    def ensure_mixin_command_exist
      return if command?('mixin')

      raise '`mixin` command is not valid!'
    end

    def command?(name)
      `which #{name}`
      $CHILD_STATUS.success?
    end
  end
end
