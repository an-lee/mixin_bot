# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Transfer do
  it 'transfer asset to multisig' do
    trace_id = SecureRandom.uuid
    res =
      MixinBot
      .api
      .create_multisig_transaction(
        PIN_CODE,
        {
          asset_id: CNB_ASSET_ID,
          receivers: MULTI_SIGN_MEMBERS,
          threshold: 3,
          amount: 0.00000001,
          memo: 'test from MixinBot',
          trace_id: trace_id
        }
      )
    expect(res['data']&.[]('trace_id')).to eq(trace_id)
  end

  it 'transfer asset to main net' do
    trace_id = SecureRandom.uuid
    res =
      MixinBot
      .api
      .create_mainnet_transaction(
        PIN_CODE,
        {
          asset_id: CNB_ASSET_ID,
          opponent_key: 'XINRXkrW1CpocUznN5feEBGYtMLku3vRKTZDpT6wFoobYnPhtbdsKjiTp6DPCUHWm8VPrcyaRabGjbxjFR5rWFa9XU77tX6d',
          amount: 0.00000001,
          memo: 'test from MixinBot',
          trace_id: trace_id
        }
      )
    expect(res['data']&.[]('trace_id')).to eq(trace_id)
  end

  it 'Get public network-wide deposit records' do
    res =
      MixinBot
      .api
      .transactions

    expect(res['data']&.[](0)&.[]('type')).to eq('transaction')
  end
end
