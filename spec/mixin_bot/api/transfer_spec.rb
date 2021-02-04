# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Transfer do
  it 'transfer asset to user' do
    trace_id = SecureRandom.uuid
    res =
      MixinBot
      .api
      .create_transfer(
        PIN_CODE,
        {
          asset_id: CNB_ASSET_ID,
          opponent_id: TEST_UID,
          amount: 0.00000001,
          memo: 'test from MixinBot',
          trace_id: trace_id
        }
      )
    expect(res['data']&.[]('trace_id')).to eq(trace_id)
  end

  it 'read transfer' do
    trace_id = '2fc389b8-e2de-417b-a5cb-409f063217f5'
    res = MixinBot.api.read_transfer(trace_id)

    expect(res['data']&.[]('trace_id')).to eq(trace_id)
  end
end
