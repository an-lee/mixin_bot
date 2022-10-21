# frozen_string_literal: true

module MVM
  class Nft
    RPC_URL = 'https://geth.mvm.dev'
    MIRROR_ADDRESS = '0xC193486e6Bf3E8461cb8fcdF178676a5D75c066A'

    attr_reader :client, :mirror

    def initialize
      @client = Eth::Client.create RPC_URL
      @mirror = Eth::Contract.from_abi name: 'Mirror', address: MIRROR_ADDRESS, abi: File.open(File.expand_path('./abis/mirror.json', __dir__)).read
    end

    def collection_from_contract(address)
      collection = @client.call @mirror, 'collections', address
      return if collection.zero?

      MixinBot::Utils::UUID.new(hex: collection.to_fs(16)).unpacked
    end

    def contract_from_collection(uuid)
      collection = uuid.to_s.gsub('-', '').to_i(16)
      contract = @client.call @mirror, 'contracts', collection
      address = Eth::Address.new contract
      return unless address.valid?

      address.checksummed
    end

    def owner_of(collection_id, token_id)
      address = contract_from_collection collection_id
      return if address.blank? || address.to_i(16).zero?

      contract = Eth::Contract.from_abi name: 'Collectible', address: address, abi: File.open(File.expand_path('./abis/erc721.json', __dir__)).read
      owner = @client.call contract, 'ownerOf', token_id.to_i
      address = Eth::Address.new owner
      return unless address.valid?

      address.checksummed
    rescue IOError
      nil
    end

    def token_of_owner_by_index(contract, owner, index)
      contract = Eth::Contract.from_abi name: 'Collectible', address: contract, abi: File.open(File.expand_path('./abis/erc721.json', __dir__)).read

      @client.call contract, 'tokenOfOwnerByIndex', owner, index
    rescue IOError
      nil
    end
  end
end
