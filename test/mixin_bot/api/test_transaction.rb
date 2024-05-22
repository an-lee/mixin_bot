# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestTransaction < Minitest::Test
    def setup
      skip 'No config file found' unless MixinBot.config.valid?
    end

    def test_build_object_transaction
      extra = 'May the HOPE be with you!'
      tx = MixinBot.api.build_object_transaction extra

      raw = MixinBot.utils.encode_raw_transaction tx

      request_id = SecureRandom.uuid
      request = MixinBot.api.create_safe_transaction_request(request_id, raw)['data']

      assert_equal request.first['request_id'], request_id
    end
  end
end
