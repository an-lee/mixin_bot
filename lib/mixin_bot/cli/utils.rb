# frozen_string_literal: true

module MixinBot
  class CLI < Thor
    desc 'encrypt PIN', 'encrypt PIN using private key'
    option :keystore, type: :string, aliases: '-k', required: true, desc: 'keystore or keystore.json file path'
    option :iterator, type: :string, aliases: '-i', desc: 'Iterator'
    def encrypt(pin)
      log api_instance.encrypt_pin pin.to_s, iterator: options[:iterator]
    end

    desc 'unique UUIDS', 'generate unique UUID for two or more UUIDs'
    def unique(*uuids)
      log MixinBot::Utils.unique_uuid(*uuids)
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

    desc 'rsa', 'generate RSA key'
    def rsa
      log MixinBot::Utils.generate_rsa_key
    end

    desc 'ed25519', 'generate Ed25519 key'
    def ed25519
      log MixinBot::Utils.generate_ed25519_key
    end
  end
end
