# frozen_string_literal: true

module MixinBot
  class CLI < Thor
    desc 'encrypt PIN', 'encrypt PIN using private key'
    option :keystore, type: :string, aliases: '-k', required: true, default: '~/.mixinbot/keystore.json', desc: 'Specify keystore.json file path'
    option :iterator, type: :string, aliases: '-i', desc: 'Iterator'
    def encrypt(pin)
      log api_instance.encrypt_pin options[:pin].to_s, iterator: options[:iterator]
    end

    desc 'unique UUIDS', 'generate unique UUID for two or more UUIDs'
    def unique(*uuids)
      uuids.sort
      r = uuids.first
      uuids.each_with_index do |uuid, i|
        r = MixinBot::Utils.unique_uuid(r, uuid) if i.positive?
      end

      log r
    end

    desc 'generatetrace HASH', 'generate trace ID from Tx hash'
    def generatetrace(hash)
      log MixinBot::Utils.generate_trace_from_hash(hash)
    end

    desc 'decodetx TRANSACTION', 'decode raw transaction'
    def decodetx(transaction)
      log MixinBot::Utils.decode_raw_transaction(transaction)
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
