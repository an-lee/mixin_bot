# frozen_string_literal: true

require 'test_helper'

module MVM
  class TestBridge < Minitest::Test
    def setup
    end

    def test_bridge_info
      r = MVM.bridge.info

      refute_nil r
    end

    def test_bridge_user
      r = MVM.bridge.user '0xF376516D190c8e5f455C299fD191e93Bf4624245'
      refute_nil r['user']['user_id']
    end
  end
end
