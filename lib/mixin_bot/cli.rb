# frozen_string_literal: true

require 'thor'
require 'yaml'
require 'json'
require_relative './cli/node'
require_relative './cli/me.rb'
require_relative './cli/multisig.rb'

module MixinBot
  class CLI < Thor
    class_option :config, type: :string, aliases: '-c', desc: 'Specify mixin bot config'
    class_option :apihost, type: :string, aliases: '-a', desc: 'Specify mixin api host, default as api.mixin.one'

    attr_reader :config, :api

    def initialize(*args)
      super
      if File.exist? options[:config].to_s
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

    desc 'version', 'Distay MixinBot version'
    def version
      puts MixinBot::VERSION
    end

    def self.exit_on_failure?
      true
    end

    private

    def api_method(method, *args)
      if api.nil?
        puts 'MixinBot api not initialized!'
        return
      end

      res = api&.public_send method, args
      puts res.inspect

      [res, res && res['error'].nil?]
    rescue MixinBot::Errors => e
      puts e
    end
  end
end
