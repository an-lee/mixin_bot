# frozen_string_literal: true

require 'awesome_print'
require 'cli/ui'
require 'thor'
require 'yaml'
require 'json'
require_relative './cli/node'
require_relative './cli/me.rb'
require_relative './cli/multisig.rb'

module MixinBot
  class CLI < Thor
    # https://github.com/Shopify/cli-ui
    UI = ::CLI::UI

    class_option :apihost, type: :string, aliases: '-a', desc: 'Specify mixin api host, default as api.mixin.one'
    class_option :pretty, type: :boolean, aliases: '-p', desc: 'Print output in pretty'

    attr_reader :config, :api

    def initialize(*args)
      super
      if File.exist? options[:config].to_s
        @config =
          begin
            YAML.load_file options[:config]
          rescue StandardError => e
            log UI.fmt(
              format(
                '{{x}} %<file>s is not a valid .yml file',
                file: options[:config]
              )
            )
            UI::Frame.open('{{x}}', color: :red) do
              log e
            end
          end
      elsif options[:config]
        @confg =
          begin
            JSON.parse options[:config]
          rescue StandardError => e
            log UI.fmt(
              format(
                '{{x}} Failed to parse %<config>s',
                config: options[:config]
              )
            )
            UI::Frame.open('{{x}}', color: :red) do
              log e
            end
          end
      end

      return unless @config

      MixinBot.api_host = options[:apihost]
      @api ||=
        begin
          MixinBot::API.new(
            client_id: @config['client_id'],
            client_secret: @config['client_secret'],
            session_id: @config['session_id'],
            pin_token: @config['pin_token'],
            private_key: @config['private_key'],
            pin_code: @config['pin_code']
          )
        rescue StandardError => e
          log UI.fmt '{{x}}: Failed to initialize api, maybe your config is incorrect.'
          UI.Frame.open('{{x}}', color: :red) do
            log e
          end
        end
    end

    desc 'node', 'mixin node commands helper'
    subcommand 'node', MixinBot::NodeCLI

    desc 'version', 'Distay MixinBot version'
    def version
      log MixinBot::VERSION
    end

    def self.exit_on_failure?
      true
    end

    private

    def api_method(method, *args, **params)
      if api.nil?
        log UI.fmt '{{x}} MixinBot api not initialized!'
        return
      end

      res = if args.empty? && params.empty?
              api&.public_send method
            elsif args.empty? && !params.empty?
              api&.public_send method params
            elsif !args.empty? && params.empty?
              api&.public_send method, args
            else
              args.push params
              api&.public_send method, args
            end
      log res

      [res, res && res['error'].nil?]
    rescue MixinBot::Errors => e
      UI::Frame.open('{{x}}', color: :red) do
        log e
      end
    end

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
