# frozen_string_literal: true

require 'active_support/all'
require 'http'
require 'eth'

require_relative './mvm/bridge'
require_relative './mvm/client'
require_relative './mvm/nft'
require_relative './mvm/scan'

module MVM
  class Error < StandardError; end
  class HttpError < Error; end
  class ResponseError < Error; end

  def self.bridge
    @bridge ||= MVM::Bridge.new
  end

  def self.nft
    @nft ||= MVM::Nft.new
  end

  def self.scan
    @scan ||= MVM::Scan.new
  end
end
