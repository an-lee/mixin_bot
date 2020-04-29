# frozen_string_literal: true

module MixinBot
  class CLI < Thor
    desc 'get_all_multisigs', 'fetch all utxos'
    option :config, required: true, aliases: '-c'
    def all_multisigs
      api_method(:get_all_multisigs)
    end
  end
end
