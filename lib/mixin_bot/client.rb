# frozen_string_literal: true

module MixinBot
  ##
  # HTTP client for making requests to the Mixin Network API.
  #
  # The Client handles:
  # - HTTP connection management
  # - Request authentication via JWT tokens
  # - JSON encoding/decoding
  # - Error handling and response parsing
  # - Automatic retry logic
  #
  # == Usage
  #
  # The Client is typically created automatically by the API class,
  # but can be instantiated directly if needed:
  #
  #   config = MixinBot::Configuration.new(...)
  #   client = MixinBot::Client.new(config)
  #   response = client.get('/me')
  #
  # == Error Handling
  #
  # The client automatically raises appropriate exceptions based on
  # API error responses:
  # - UnauthorizedError (401, 20121)
  # - ForbiddenError (403, 20116, 10002, 429)
  # - NotFoundError (404)
  # - UserNotFoundError (10404)
  # - InsufficientBalanceError (20117)
  # - PinError (20118, 20119)
  # - InsufficientPoolError (30103)
  # - ResponseError (other errors)
  #
  class Client
    ##
    # The HTTPS scheme used for API requests.
    SERVER_SCHEME = 'https'

    ##
    # @return [MixinBot::Configuration] the configuration
    attr_reader :config

    ##
    # @return [Faraday::Connection] the HTTP connection
    attr_reader :conn

    ##
    # Initializes a new Client instance.
    #
    # Sets up the HTTP connection with:
    # - JSON request/response handling
    # - Automatic retry on failures
    # - Custom User-Agent header
    # - Optional debug logging
    #
    # @param config [MixinBot::Configuration] the configuration (defaults to global config)
    #
    def initialize(config)
      @config = config || MixinBot.config
      @conn = Faraday.new(
        url: "#{SERVER_SCHEME}://#{config.api_host}",
        headers: {
          'Content-Type' => 'application/json',
          'User-Agent' => "mixin_bot/#{MixinBot::VERSION}"
        }
      ) do |f|
        f.request :json
        f.request :retry
        f.response :json
        f.response :logger if config.debug
      end
    end

    ##
    # Performs a GET request to the Mixin API.
    #
    # @param path [String] the API endpoint path
    # @param args [Array] positional arguments
    # @param kwargs [Hash] keyword arguments including query parameters
    # @return [Hash] the parsed response
    # @raise [MixinBot::Error] on API errors
    #
    def get(path, *, **)
      request(:get, path, *, **)
    end

    ##
    # Performs a POST request to the Mixin API.
    #
    # @param path [String] the API endpoint path
    # @param args [Array] positional arguments
    # @param kwargs [Hash] keyword arguments for request body
    # @return [Hash] the parsed response
    # @raise [MixinBot::Error] on API errors
    #
    def post(path, *, **)
      request(:post, path, *, **)
    end

    private

    def request(verb, path, *args, **kwargs)
      access_token = kwargs.delete :access_token
      exp_in = kwargs.delete(:exp_in) || 600
      scp = kwargs.delete(:scp) || 'FULL'

      kwargs.compact!
      body =
        if verb == :post
          if args.present?
            args.to_json
          else
            kwargs.to_json
          end
        else
          ''
        end

      path = "#{path}?#{URI.encode_www_form(kwargs.sort_by { |k, _v| k })}" if verb == :get && kwargs.present?
      access_token ||=
        MixinBot.utils.access_token(
          verb.to_s.upcase,
          path,
          body,
          exp_in:,
          scp:,
          app_id: config.app_id,
          session_id: config.session_id,
          private_key: config.session_private_key
        )
      authorization = format('Bearer %<access_token>s', access_token:)

      response =
        case verb
        when :get
          @conn.get path, nil, { Authorization: authorization }
        when :post
          @conn.post path, body, { Authorization: authorization }
        end

      result = response.body

      if result['error'].blank?
        result.merge! result['data'] if result['data'].is_a? Hash
        return result
      end

      errmsg = "#{verb.upcase} | #{path} | #{body}, errcode: #{result['error']['code']}, errmsg: #{result['error']['description']}, request_id: #{response&.[]('X-Request-Id')}, server_time: #{response&.[]('X-Server-Time')}'"

      case result['error']['code']
      when 401, 20121
        raise UnauthorizedError, errmsg
      when 403, 20116, 10002, 429
        raise ForbiddenError, errmsg
      when 404
        raise NotFoundError, errmsg
      when 20117
        raise InsufficientBalanceError, errmsg
      when 20118, 20119
        raise PinError, errmsg
      when 30103
        raise InsufficientPoolError, errmsg
      when 10404
        raise UserNotFoundError, errmsg
      else
        raise ResponseError, errmsg
      end
    end
  end
end
