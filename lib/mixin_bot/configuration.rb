module MixinBot
  class Configuration
    CONFIGURABLE_ATTRS = %i[
      app_id
      client_secret
      session_id
      session_private_key
      server_public_key
      spend_key
      pin
      api_host
      blaze_host
    ].freeze
    attr_accessor *CONFIGURABLE_ATTRS

    def initialize(**kwargs)
      @app_id = kwargs[:app_id] || kwargs[:client_id]
      @client_secret = kwargs[:client_secret]
      @session_id = kwargs[:session_id]
      @api_host = kwargs[:api_host] || 'api.mixin.one'
      @blaze_host = kwargs[:blaze_host] || 'blaze.mixin.one'

      @session_private_key = decode_key kwargs[:session_private_key] || kwargs[:private_key]
      @server_public_key = decode_key kwargs[:server_public_key] || kwargs[:pin_token]
      @spend_key = decode_key kwargs[:spend_key]
      @pin = decode_key(kwargs[:pin]) || @spend_key
    end

    def session_private_key=(key)
      _private_key = decode_key key

      @session_private_key =
        if _private_key.size == 32
          JOSE::JWA::Ed25519.keypair(_private_key).last
        else
          _private_key
        end

    end

    def server_public_key=(key)
      @server_public_key = decode_key key
    end

    def spend_key=(key)
      _private_key = decode_key key

      @spend_key =
        if _private_key.size == 32
          JOSE::JWA::Ed25519.keypair(_private_key).last
        else
          _private_key
        end
    end

    def pin=(key)
      _private_key = decode_key key

      @pin =
        if _private_key.size == 32
          JOSE::JWA::Ed25519.keypair(_private_key).last
        else
          _private_key
        end
    end

    private

    def decode_key(key)
      MixinBot::Utils.decode_key key
    end
  end
end
