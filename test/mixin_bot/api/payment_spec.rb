# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Payment do
  it 'generate pay url' do
    res = MixinBot.api.pay_url(
      recipient_id: MixinBot.config.app_id,
      asset_id: CNB_ASSET_ID,
      amount: 0.00000001,
      trace: SecureRandom.uuid,
      memo: 'test from MixinBot'
    )

    expect(res).to start_with('https://mixin.one/pay?recipient=')
  end

  it 'verity a pending payment' do
    trace_id = SecureRandom.uuid
    res = MixinBot.api.verify_payment(
      asset_id: CNB_ASSET_ID,
      opponent_id: MixinBot.config.app_id,
      amount: 0.00000001,
      trace: trace_id
    )

    expect(res['data']&.[]('status')).to eq('pending')
  end

  it 'verity a paid payment' do
    trace_id = 'de72d37a-b867-481f-90b4-cb5f06926c8b'
    res = MixinBot.api.verify_payment(
      asset_id: CNB_ASSET_ID,
      opponent_id: MixinBot.config.app_id,
      amount: 0.00000001,
      trace: trace_id
    )

    expect(res['data']&.[]('status')).to eq('paid')
  end
end
