# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestOutput < Minitest::Test
    def setup
      skip 'No config file found' unless MixinBot.config.valid?

      MixinBot.config.debug = true
    end

    def test_safe_outputs
      res = MixinBot.api.safe_outputs

      assert_equal res['data'].class, Array
    end

    def test_safe_output
      outputs = MixinBot.api.safe_outputs
      skip "no outputs found: #{outputs}" if outputs['data'].blank?

      res = MixinBot.api.safe_output outputs['data'].first['output_id']
      assert_equal res['data']['output_id'], outputs['data'].first['output_id']
    end
  end
end
