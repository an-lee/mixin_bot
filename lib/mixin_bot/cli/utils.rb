# frozen_string_literal: true

module MixinBot
  class CLI < Thor
    desc 'encryptpin', 'encrypt PIN'
    option :keystore, type: :string, aliases: '-k', default: '~/.mixinbot/keystore.json', desc: 'Specify keystore.json file path'
    option :pin, type: :numeric, aliases: '-p', desc: 'Encrypt PIN code'
    option :iterator, type: :string, aliases: '-i', desc: 'Iterator'
    def encryptpin
      pin = options[:pin] || keystore['pin']
      log api_instance.encrypt_pin options[:pin].to_s, iterator: options[:iterator]
    end
  end
end
