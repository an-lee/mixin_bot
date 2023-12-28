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

    def test_create_safe_user
      keystore = MixinBot.api.create_safe_user('Bot User')

      # save keystore
      File.open("./tmp/#{keystore[:app_id]}-keystore.json", 'w') do |f|
        f.write keystore.to_json
      end

      assert keystore.key?(:spend_key)
    end
  end
end
