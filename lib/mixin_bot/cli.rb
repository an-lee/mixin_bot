# frozen_string_literal: true

require 'thor'
require 'yaml'
require 'json'
require_relative './cli/node'

module MixinBot
  class CLI < Thor
    default_command :help
    class_option :config, type: :string, aliases: '-c', desc: 'Specify mixin bot config'
    class_option :apihost, type: :string, aliases: '-a', desc: 'Specify mixin api host, default as api.mixin.one'

    attr_reader :config, :api

    def initialize(*args)
      super
      if File.exist? options[:config]
        @config =
          begin
            YAML.load_file options[:config]
          rescue StandardError => e
            puts 'Failed to read CONFIG'
            puts format('%<file>s is not a valid .yml file', file: options[:config])
            puts e.inspect
          end
      elsif options[:config]
        @confg =
          begin
            JSON.parse options[:config]
          rescue StandardError => e
            puts `Failed to parse #{options[:config]}`
            puts e.inspect
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
          puts 'Failed to initialize api, maybe your config is incorrect.'
          puts e.inspect
        end
    end

    desc 'node', 'mixin node commands helper'
    subcommand 'node', MixinBot::NodeCLI

    desc 'read_me', 'fetch mixin bot profile'
    option :config, required: true, aliases: '-c'
    def read_me
      api_method(:read_me)
    rescue MixinBot::Errors => e
      puts e
    end

    desc 'read_assets', 'fetch mixin bot assets'
    option :config, required: true, aliases: '-c'
    def read_assets
      api_method(:read_assets)
    rescue MixinBot::Errors => e
      puts e
    end

    desc 'cal_assets_as_usd', 'fetch mixin bot assets'
    option :config, required: true, aliases: '-c'
    def cal_assets_as_usd
      assets, success = read_assets
      return unless success

      puts assets['data'].map(&->(asset) { asset['balance'].to_f * asset['price_usd'].to_f }).sum
    end

    desc 'version', 'Distay MixinBot version'
    def version
      puts MixinBot::VERSION
    end

    def self.exit_on_failure?
      true
    end

    private

    def api_method(method)
      if api.nil?
        puts 'MixinBot api not initialized!'
        return
      end

      res = api&.public_send method
      puts res.inspect

      [res, res && res['error'].nil?]
    end
  end
end
