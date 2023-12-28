# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestSnapshot < Minitest::Test
    def setup
      skip 'No config file found' unless MixinBot.config.valid?
    end

    def test_safe_snapshots
      res = MixinBot.api.safe_snapshots limit: 5

      assert_equal res['data'][0]['type'], 'snapshot'
    end

    def test_safe_snapshot_notification
      output = MixinBot.api.safe_outputs(state: :spent)['data'].first

      r = MixinBot.api.create_safe_snapshot_notification(
        transaction_hash: output['transaction_hash'],
        output_id: 0,
        receiver_id: MixinBot.config.app_id
      )

      refute_nil r['data']
    end
  end
end
