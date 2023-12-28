# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestUser < Minitest::Test
    def setup
      skip 'No config file found' unless MixinBot.config.valid?
    end

    def test_read_user
      r = MixinBot.api.read_user TEST_UID
      
      assert_equal r['data']['user_id'], TEST_UID
    end

    def test_create_user
      r = MixinBot.api.create_user('Bot User')

      assert_equal r['data']['full_name'], 'Bot User'
    end

    def test_search_user
      r = MixinBot.api.search_user(TEST_MIXIN_ID)

      assert_equal r['data']['identity_number'], TEST_MIXIN_ID
    end

    def test_fetch_users
      r = MixinBot.api.fetch_users([TEST_UID, MixinBot.config.app_id])

      assert r['data'].is_a?(Array)
    end

    def test_safe_register_user
      r = MixinBot.api.create_user('Bot User')
      session_key = r[:key]
      counter = r['data']['tip_counter']
      assert counter == 0
      refute_nil r['data']['pin_token_base64']

      user_api = MixinBot::API.new(
        app_id: r['data']['user_id'],
        session_id: r['data']['session_id'],
        private_key: r[:key][:private_key],
        pin_token: r['data']['pin_token_base64']
      )
      user_api.config.debug = true
      assert user_api.config.app_id == r['data']['user_id']

      spend_key = JOSE::JWA::Ed25519.keypair

      keystore = {
        app_id: user_api.config.app_id,
        session_id: user_api.config.session_id,
        session_private_key: session_key[:private_key],
        pin_token: Base64.urlsafe_encode64(user_api.config.server_public_key, padding: false),
        spend_key: spend_key[1].unpack1('H*')
      }

      File.open("./tmp/#{keystore[:app_id]}-keystore.json", 'w') do |f|
        f.write keystore.to_json
      end

      # update tip pin
      r = user_api.update_pin pin: MixinBot.utils.tip_public_key(spend_key[0], counter:)
      assert r['data']['tip_counter'] == 1

      # wait for tip pin update in server
      sleep 2

      r = user_api.safe_register spend_key[1].unpack1('H*')
      assert r['data']['user_id'] == user_api.config.app_id
    end
  end
end
