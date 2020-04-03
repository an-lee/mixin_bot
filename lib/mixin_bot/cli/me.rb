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

      log assets['data'].map(&->(asset) { asset['balance'].to_f * asset['price_usd'].to_f }).sum
    end

    desc 'read_asset', 'fetch specific asset of mixin bot'
    option :config, required: true, aliases: '-c'
    option :asset_id, required: true, aliases: '-a'
    def read_asset
      api_method(:read_asset, options[:asset_id])
    end
  end
end
