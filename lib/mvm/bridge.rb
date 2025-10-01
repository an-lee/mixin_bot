# frozen_string_literal: true

module MVM
  ##
  # Bridge client for MVM cross-chain operations.
  #
  # The Bridge facilitates communication between Mixin Network and MVM,
  # enabling cross-chain transfers and user registration.
  #
  # == Usage
  #
  #   bridge = MVM.bridge
  #   info = bridge.info
  #   user_info = bridge.user(public_key)
  #
  class Bridge
    ##
    # @return [MVM::Client] the HTTP client for bridge operations
    attr_reader :client

    ##
    # Initializes a new Bridge instance.
    #
    # Creates an HTTP client connected to the MVM bridge service.
    #
    def initialize
      @client = MVM::Client.new 'bridge.mvm.dev'
    end

    ##
    # Retrieves bridge service information.
    #
    # Returns general information about the bridge service including
    # supported features, version, and status.
    #
    # @return [Hash] bridge information
    #
    # @example
    #   bridge = MVM.bridge
    #   info = bridge.info
    #   puts info
    #
    def info
      client.get '/'
    end

    ##
    # Retrieves or creates user information on the bridge.
    #
    # Registers a user's public key with the bridge service,
    # enabling them to perform cross-chain operations.
    #
    # @param public_key [String] the user's public key
    # @return [Hash] user information including bridge address
    #
    # @example
    #   bridge = MVM.bridge
    #   user = bridge.user('0x1234...')
    #   puts user['contract']
    #
    def user(public_key)
      path = '/users'

      payload = {
        public_key:
      }

      client.post path, **payload
    end
  end
end
