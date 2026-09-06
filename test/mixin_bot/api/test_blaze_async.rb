# frozen_string_literal: true

require 'test_helper'

module MixinBot
  ##
  # Offline unit tests for +MixinBot::API::BlazeAsync+ — the fiber-based
  # sibling of +API::Blaze#blaze+.
  #
  # The transport itself is out of scope here (it needs a live WebSocket
  # endpoint); these tests stub +Async::WebSocket::Client.connect+ and assert
  # the contract +blaze_async+ must uphold: same URL, subprotocol, and
  # headers as +blaze+; forced HTTP/1 ALPN; handler and endpoint-option
  # passthrough; and the block-less "returns a client the caller drives"
  # result shape.
  class TestBlazeAsync < Minitest::Test
    def setup
      OfflineConfig.apply!
    end

    def capture_connect(&call)
      captured = {}
      original = Async::WebSocket::Client.method(:connect)
      stub = lambda do |endpoint, **options|
        captured[:endpoint] = endpoint
        captured[:options] = options
        :connection
      end

      Async::WebSocket::Client.define_singleton_method(:connect, stub)
      captured[:result] = call.call
      captured
    ensure
      Async::WebSocket::Client.define_singleton_method(:connect, original)
    end

    def test_returns_the_connect_result_unchanged
      captured = capture_connect { MixinBot.api.blaze_async }

      assert_equal :connection, captured[:result]
    end

    def test_builds_the_endpoint_from_the_configured_blaze_host
      captured = capture_connect { MixinBot.api.blaze_async }

      assert_includes captured[:endpoint].to_s, MixinBot.config.blaze_host
    end

    def test_forces_the_http1_alpn_upgrade_path
      captured = capture_connect { MixinBot.api.blaze_async }

      assert_equal Async::HTTP::Protocol::HTTP11.names, captured[:endpoint].alpn_protocols
    end

    def test_negotiates_the_mixin_blaze_subprotocol
      captured = capture_connect { MixinBot.api.blaze_async }

      assert_equal ['Mixin-Blaze-1'], captured[:options][:protocols]
    end

    def test_sends_the_bearer_authorization_and_user_agent_headers
      captured = capture_connect { MixinBot.api.blaze_async }
      headers = captured[:options][:headers]

      assert_match(/\ABearer .+\z/, headers['Authorization'])
      assert_equal "mixin_bot/#{MixinBot::VERSION}", headers['User-Agent']
    end

    def test_passes_the_handler_through_to_the_client
      handler = Class.new(Async::WebSocket::Connection)
      captured = capture_connect { MixinBot.api.blaze_async(handler: handler) }

      assert_equal handler, captured[:options][:handler]
    end

    def test_defaults_the_handler_to_the_library_connection
      captured = capture_connect { MixinBot.api.blaze_async }

      assert_equal Async::WebSocket::Connection, captured[:options][:handler]
    end

    def test_forwards_endpoint_options_to_the_endpoint
      captured = capture_connect { MixinBot.api.blaze_async(endpoint_options: { timeout: 42 }) }

      assert_equal 42, captured[:endpoint].timeout
    end
  end
end
