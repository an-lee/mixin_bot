# frozen_string_literal: true

require 'test_helper'

module MVM
  class TestScan < Minitest::Test
    def setup
    end

    def test_scan_tokens
      r = MVM.scan.tokens '0xF376516D190c8e5f455C299fD191e93Bf4624245'
      refute_nil r
    end
  end
end
