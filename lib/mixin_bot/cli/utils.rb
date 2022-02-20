# frozen_string_literal: true

module MixinBot
  class CLI < Thor
    desc 'encryptpin', 'encrypt PIN'
    option :keystore, type: :string, aliases: '-k', required: true, default: '~/.mixinbot/keystore.json', desc: 'Specify keystore.json file path'
    option :pin, type: :numeric, aliases: '-p', desc: 'Encrypt PIN code'
    option :iterator, type: :string, aliases: '-i', desc: 'Iterator'
    def encryptpin
      pin = options[:pin] || keystore['pin']
      log api_instance.encrypt_pin options[:pin].to_s, iterator: options[:iterator]
    end

    desc 'uniqueuuid', 'generate unique UUID for two or more UUIDs'
    option :uuids, type: :array, required: true, aliases: '-u', desc: 'UUIDs to generate'
    def uniqueuuid
      uuids = options[:uuids].sort
      r = uuids.first
      uuids.each_with_index do |uuid, i|
        r = MixinBot::Utils.unique_uuid(r, uuid) if i.positive?
      end

      log r
    end

    desc 'txhashtotrace', 'generate Tx trace ID from Tx hash'
    option :hash, type: :string, required: true, aliases: '-h', desc: 'Transaction hash'
    def txhashtotrace
      log MixinBot::Utils.generate_trace_from_hash(options[:hash])
    end

    desc 'decoderawtransaction', 'decode raw transaction'
    option :tx, type: :string, required: true, aliases: '-x', desc: 'Raw Transaction'
    def decoderawtransaction
      log MixinBot::Utils.decode_raw_transaction(options[:tx])
    end

    desc 'nftmemo', 'memo for mint NFT'
    option :collection, type: :string, required: true, aliases: '-c', desc: 'Collection ID, UUID'
    option :token, type: :numeric, required: true, aliases: '-t', desc: 'Token ID, Integer'
    option :hash, type: :string, required: true, aliases: '-h', desc: 'Hash of NFT metadata, 256-bit string'
    def nftmemo
      log MixinBot::Utils.nft(options[:collection], options[:token], options[:hash])
    end
  end
end
