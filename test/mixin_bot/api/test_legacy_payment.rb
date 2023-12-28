# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestLegacyPayment < Minitest::Test
    def test_generate_pay_url
      res = MixinBot.api.pay_url(
        recipient_id: MixinBot.config.app_id,
        asset_id: CNB_ASSET_ID,
        amount: 0.00000001,
        trace: SecureRandom.uuid,
        memo: 'test from MixinBot'
      )

      assert res.start_with?('https://mixin.one/pay?recipient=')
    end

    def test_verify_pending_payment
      trace_id = SecureRandom.uuid
      res = MixinBot.api.verify_payment(
        asset_id: CNB_ASSET_ID,
        opponent_id: MixinBot.config.app_id,
        amount: 0.00000001,
        trace: trace_id
      )

      assert_equal res['data']['status'], 'pending'
    end

    def test_verify_paid_payment
      trace_id = 'de72d37a-b867-481f-90b4-cb5f06926c8b'
      res = MixinBot.api.verify_payment(
        asset_id: CNB_ASSET_ID,
        opponent_id: MixinBot.config.app_id,
        amount: 0.00000001,
        trace: trace_id
      )

      assert_equal res['data']['status'], 'paid'
    end
  end
end
