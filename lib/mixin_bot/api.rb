# frozen_string_literal: true

require_relative 'client'
require_relative 'configuration'
require_relative 'api/address'
require_relative 'api/app'
require_relative 'api/asset'
require_relative 'api/attachment'
require_relative 'api/auth'
require_relative 'api/blaze'
require_relative 'api/conversation'
require_relative 'api/encrypted_message'
require_relative 'api/inscription'
require_relative 'api/legacy_collectible'
require_relative 'api/legacy_multisig'
require_relative 'api/legacy_output'
require_relative 'api/legacy_payment'
require_relative 'api/legacy_snapshot'
require_relative 'api/legacy_transaction'
require_relative 'api/legacy_transfer'
require_relative 'api/me'
require_relative 'api/message'
require_relative 'api/multisig'
require_relative 'api/output'
require_relative 'api/payment'
require_relative 'api/pin'
require_relative 'api/rpc'
require_relative 'api/snapshot'
require_relative 'api/tip'
require_relative 'api/transaction'
require_relative 'api/transfer'
require_relative 'api/user'
require_relative 'api/withdraw'

module MixinBot
  class API
    attr_reader :config, :client

    def initialize(**kwargs)
      @config =
        if kwargs.present?
          MixinBot::Configuration.new(**kwargs)
        else
          MixinBot.config
        end

      @client = Client.new(@config)
    end

    def utils
      MixinBot::Utils
    end

    def client_id
      config.app_id
    end

    def access_token(method, uri, body, **kwargs)
      utils.access_token(
        method,
        uri,
        body,
        exp_in: kwargs.delete(:exp_in) || 600,
        scp: kwargs.delete(:scp) || 'FULL',
        app_id: config.app_id,
        session_id: config.session_id,
        private_key: config.session_private_key
      )
    end

    def encode_raw_transaction(txn)
      utils.encode_raw_transaction txn
    end

    def decode_raw_transaction(raw)
      utils.decode_raw_transaction raw
    end

    def generate_trace_from_hash(hash, output_index = 0)
      utils.generate_trace_from_hash hash, output_index
    end

    # Use a mixin software to implement transaction build
    def encode_raw_transaction_native(json)
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

    include MixinBot::API::Address
    include MixinBot::API::App
    include MixinBot::API::Asset
    include MixinBot::API::Attachment
    include MixinBot::API::Auth
    include MixinBot::API::Blaze
    include MixinBot::API::Conversation
    include MixinBot::API::EncryptedMessage
    include MixinBot::API::Inscription
    include MixinBot::API::LegacyCollectible
    include MixinBot::API::LegacyMultisig
    include MixinBot::API::LegacyOutput
    include MixinBot::API::LegacyPayment
    include MixinBot::API::LegacySnapshot
    include MixinBot::API::LegacyTransaction
    include MixinBot::API::LegacyTransfer
    include MixinBot::API::Me
    include MixinBot::API::Message
    include MixinBot::API::Multisig
    include MixinBot::API::Output
    include MixinBot::API::Payment
    include MixinBot::API::Pin
    include MixinBot::API::Rpc
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
