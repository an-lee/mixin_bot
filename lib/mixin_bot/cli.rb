# frozen_string_literal: true

require 'awesome_print'
require 'cli/ui'
require 'thor'
require 'yaml'
require 'json'
require_relative './cli/api'
require_relative './cli/node'
require_relative './cli/utils'

module MixinBot
  class CLI < Thor
    # https://github.com/Shopify/cli-ui
    UI = ::CLI::UI

    class_option :apihost, type: :string, aliases: '-a', default: 'api.mixin.one', desc: 'Specify mixin api host'
    class_option :pretty, type: :boolean, aliases: '-r', default: true, desc: 'Print output in pretty'

    attr_reader :keystore, :api_instance

    def initialize(*args)
      super
      return if options[:keystore].blank?

      keystore =
        if File.file? options[:keystore]
          File.read options[:keystore]
        else
          options[:keystore]
        end

      @keystore =
        begin
          JSON.parse keystore
        rescue JSON::ParserError => e
          log UI.fmt(
            format(
              '{{x}} falied to parse keystore.json: %<keystore>s',
              keystore: options[:keystore]
            )
          )
        end

      return unless @keystore

      MixinBot.api_host = options[:apihost]
      @api_instance ||=
        begin
          MixinBot::API.new(
            client_id: @keystore['client_id'],
            session_id: @keystore['session_id'],
            pin_token: @keystore['pin_token'],
            private_key: @keystore['private_key']
          )
        rescue StandardError => e
          log UI.fmt '{{x}}: Failed to initialize api, maybe your keystore is incorrect.'
        end
    end

    # desc 'node', 'mixin node commands helper'
    # subcommand 'node', MixinBot::NodeCLI

    desc 'version', 'Distay MixinBot version'
    def version
      log MixinBot::VERSION
    end

    def self.exit_on_failure?
      true
    end

    private

    def log(obj)
      if options[:pretty]
        if obj.is_a? String
          puts obj
        else
          ap obj
        end
      else
        puts obj.inspect
      end
    end
  end
end
