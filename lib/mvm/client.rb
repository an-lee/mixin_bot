# frozen_string_literal: true

module MVM
  ##
  # HTTP client for MVM services.
  #
  # Handles HTTP communication with MVM services including:
  # - Bridge service
  # - NFT service
  # - Registry service
  # - Scan service
  #
  # == Features
  #
  # - Automatic JSON encoding/decoding
  # - Request retry on failures
  # - Error handling with exceptions
  # - Debug logging
  #
  # == Usage
  #
  #   client = MVM::Client.new('bridge.mvm.dev')
  #   response = client.get('/info')
  #   response = client.post('/users', public_key: '0x...')
  #
  class Client
    ##
    # The HTTPS scheme for all MVM requests.
    SERVER_SCHEME = 'https'

    ##
    # @return [String] the service host
    attr_reader :host

    ##
    # Initializes a new MVM Client.
    #
    # Sets up HTTP connection with:
    # - JSON request/response handling
    # - Automatic retry on failures
    # - Error raising on HTTP errors
    # - Debug logging
    #
    # @param host [String] the service hostname
    #
    # @example
    #   client = MVM::Client.new('bridge.mvm.dev')
    #
    def initialize(host)
      @host = host
      @conn = Faraday.new(url: "#{SERVER_SCHEME}://#{host}") do |f|
        f.request :json
        f.request :retry
        f.response :raise_error
        f.response :logger
        f.response :json
      end
    end

    ##
    # Performs a GET request.
    #
    # @param path [String] the request path
    # @param kwargs [Hash] query parameters
    # @return [Hash] the parsed response body
    #
    # @example
    #   response = client.get('/info')
    #
    def get(path, **)
      @conn.get(path, **).body
    end

    ##
    # Performs a POST request.
    #
    # @param path [String] the request path
    # @param kwargs [Hash] request body parameters
    # @return [Hash] the parsed response body
    #
    # @example
    #   response = client.post('/users', public_key: '0x...')
    #
    def post(path, **)
      @conn.post(path, **).body
    end
  end
end
