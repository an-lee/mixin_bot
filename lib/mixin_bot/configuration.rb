# frozen_string_literal: true

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
      session_private_key_curve25519
      server_public_key_curve25519
      debug
    ].freeze
    attr_accessor(*CONFIGURABLE_ATTRS)

    def initialize(**kwargs)
      @app_id = kwargs[:app_id] || kwargs[:client_id]
      @client_secret = kwargs[:client_secret]
      @session_id = kwargs[:session_id]
      @api_host = kwargs[:api_host] || 'api.mixin.one'
      @blaze_host = kwargs[:blaze_host] || 'blaze.mixin.one'
      @debug = kwargs[:debug] || false

      self.session_private_key = kwargs[:session_private_key] || kwargs[:private_key]
      self.server_public_key = kwargs[:server_public_key] || kwargs[:pin_token]
      self.spend_key = kwargs[:spend_key]
      self.pin = kwargs[:pin] || spend_key
    end

    def valid?
      %i[app_id session_id session_private_key server_public_key].all? do |attr|
        send(attr).present?
      end
    end

    def session_private_key=(key)
      return if key.blank?

      _private_key = decode_key key
      @session_private_key =
        if _private_key.size == 32
          JOSE::JWA::Ed25519.keypair(_private_key).last
        else
          _private_key
        end

      @session_private_key_curve25519 = JOSE::JWA::Ed25519.sk_to_curve25519(@session_private_key) if @session_private_key.size == 64
    end

    def server_public_key=(key)
      return if key.blank?

      @server_public_key = decode_key key
      # HEX encoded
      @server_public_key_curve25519 =
        if key.match?(/\A[a-f0-9]+\z/i)
          JOSE::JWA::Ed25519.pk_to_curve25519 @server_public_key
        else
          server_public_key
        end
    end

    def spend_key=(key)
      return if key.blank?

      _private_key = decode_key key
      @spend_key =
        if _private_key.size == 32
          JOSE::JWA::Ed25519.keypair(_private_key).last
        else
          _private_key
        end
    end

    def pin=(key)
      return if key.blank?

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
      MixinBot.utils.decode_key key
    end
  end
end
