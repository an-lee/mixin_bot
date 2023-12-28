# frozen_string_literal: true

require 'active_support/all'
require 'eth'

require_relative 'mvm/bridge'
require_relative 'mvm/client'
require_relative 'mvm/nft'
require_relative 'mvm/registry'
require_relative 'mvm/scan'

module MVM
  RPC_URL = 'https://geth.mvm.dev'
  MIRROR_ADDRESS = '0xC193486e6Bf3E8461cb8fcdF178676a5D75c066A'
  REGISTRY_ADDRESS = '0x3c84B6C98FBeB813e05a7A7813F0442883450B1F'

  class Error < StandardError; end
  class HttpError < Error; end
  class ResponseError < Error; end

  def self.bridge
    @bridge ||= MVM::Bridge.new
  end

  def self.nft(**params)
    @nft ||= MVM::Nft.new(**params)
  end

  def self.scan
    @scan ||= MVM::Scan.new
  end

  def self.registry(**params)
    @registry ||= MVM::Registry.new(**params)
  end
end
