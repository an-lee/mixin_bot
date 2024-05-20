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
      puts tx

      raw = MixinBot.utils.encode_raw_transaction tx
      request = create_safe_transaction_request(request_id, raw)['data']

      puts request

      refute_nil request
    end
  end
end
