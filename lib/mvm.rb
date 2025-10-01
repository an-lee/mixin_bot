# frozen_string_literal: true

require 'active_support/all'
require 'eth'

require_relative 'mvm/bridge'
require_relative 'mvm/client'
require_relative 'mvm/nft'
require_relative 'mvm/registry'
require_relative 'mvm/scan'

##
# = MVM (Mixin Virtual Machine)
#
# MVM module provides integration with Mixin Virtual Machine, an Ethereum-compatible
# virtual machine running on Mixin Network.
#
# == Overview
#
# MVM enables smart contract execution on Mixin Network with:
# - EVM compatibility (Ethereum Virtual Machine)
# - High performance and low cost
# - Seamless integration with Mixin Network assets
# - NFT support (ERC-721, ERC-1155)
# - Bridge functionality for cross-chain operations
#
# == Components
#
# [MVM::Bridge] Bridge operations for cross-chain transfers
# [MVM::Client] HTTP client for MVM services
# [MVM::Nft] NFT operations (ERC-721, ERC-1155)
# [MVM::Registry] Contract registry operations
# [MVM::Scan] Blockchain explorer interface
#
# == Constants
#
# [RPC_URL] The default RPC endpoint for MVM
# [MIRROR_ADDRESS] The mirror contract address
# [REGISTRY_ADDRESS] The registry contract address
#
# == Usage
#
# Access bridge information:
#
#   bridge = MVM.bridge
#   info = bridge.info
#
# Work with NFTs:
#
#   nft = MVM.nft
#   # NFT operations...
#
# Use the blockchain scanner:
#
#   scan = MVM.scan
#   # Scan operations...
#
# Access the registry:
#
#   registry = MVM.registry
#   # Registry operations...
#
# == References
#
# - {MVM Documentation}[https://mvm.dev]
#
module MVM
  ##
  # The default RPC URL for Mixin Virtual Machine.
  RPC_URL = 'https://geth.mvm.dev'

  ##
  # The mirror contract address for cross-chain operations.
  MIRROR_ADDRESS = '0xC193486e6Bf3E8461cb8fcdF178676a5D75c066A'

  ##
  # The registry contract address for contract management.
  REGISTRY_ADDRESS = '0x3c84B6C98FBeB813e05a7A7813F0442883450B1F'

  ##
  # Base error class for all MVM errors.
  class Error < StandardError; end

  ##
  # Raised when HTTP request to MVM service fails.
  class HttpError < Error; end

  ##
  # Raised when MVM service returns an error response.
  class ResponseError < Error; end

  ##
  # Returns a singleton Bridge instance.
  #
  # @return [MVM::Bridge] the bridge instance
  #
  def self.bridge
    @bridge ||= MVM::Bridge.new
  end

  ##
  # Returns a singleton or new NFT instance.
  #
  # @param params [Hash] optional parameters for NFT operations
  # @return [MVM::Nft] the NFT instance
  #
  def self.nft(**params)
    @nft ||= MVM::Nft.new(**params)
  end

  ##
  # Returns a singleton Scan instance.
  #
  # @return [MVM::Scan] the scan instance
  #
  def self.scan
    @scan ||= MVM::Scan.new
  end

  ##
  # Returns a singleton or new Registry instance.
  #
  # @param params [Hash] optional parameters for registry operations
  # @return [MVM::Registry] the registry instance
  #
  def self.registry(**params)
    @registry ||= MVM::Registry.new(**params)
  end
end
