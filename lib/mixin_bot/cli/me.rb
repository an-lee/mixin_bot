# frozen_string_literal: true

module MixinBot
  class CLI < Thor
    desc 'read_me', 'fetch mixin bot profile'
    option :config, required: true, aliases: '-c'
    def read_me
      api_method(:read_me)
    end

    desc 'read_assets', 'fetch mixin bot assets'
    option :config, required: true, aliases: '-c'
    def read_assets
      api_method(:read_assets)
    end

    desc 'cal_assets_as_usd', 'fetch mixin bot assets'
    option :config, required: true, aliases: '-c'
    def cal_assets_as_usd
      assets, success = read_assets
      return unless success

      puts assets['data'].map(&->(asset) { asset['balance'].to_f * asset['price_usd'].to_f }).sum
    end
  end
end
