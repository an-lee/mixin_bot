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
          trace_id:
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
          trace_id:
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

  it 'sign transaction' do
    utxos = [
      {
        'transaction_hash' => '7188d47ada4c3234019f950e85dc6bd9696d3329bd30c976d9af64b6f510a00a',
        'output_index' => 0,
        'mask' => '32f9c92f4c01ba6f830a1f24895e1469024ef403f14879651eafb634da88b7da',
        'keys' => ['3ee48ff414dacf568a1e93ba881bf7e8fa2ea0056c3e922a456c2dcf0edb51c5']
      }
    ]

    raw = '77770005b9f49cf777dc4d03bc54cd1367eebca319f8603ea1ce18910d09e2c540c630d800017188d47ada4c3234019f950e85dc6bd9696d3329bd30c976d9af64b6f510a00a000000000000000000020000000203e800013ad56d6427ed5da766c40a4cd7aabea0f61ca6e0e33c727a10600ef90fa690dc9e3488d517d1da711a86074945c9d3c2e5f607693a7a9ec02cf05b73e9d518540003fffe0100000000000223280001042a59250cf25235b3a82e71419140dbb7e32305e3518a4366967fa4e382173bed4788dca7db44632ace15fdb52ae67fff987eba1bd94b15d44894852fc796180003fffe0100000000000000000000'

    request = { 'type' => 'kernel_transaction_request', 'request_id' => '41115e9a-09d0-4957-b39b-3e4168bc17ac', 'transaction_hash' => '3e9d99a9157a9bce59dd3535f85ccb586fcfa6af97b22b363c1e6a60ceeeb952', 'asset' => 'b9f49cf777dc4d03bc54cd1367eebca319f8603ea1ce18910d09e2c540c630d8', 'amount' => '0.00001', 'extra' => '', 'state' => 'unspent', 'raw_transaction' => '77770005b9f49cf777dc4d03bc54cd1367eebca319f8603ea1ce18910d09e2c540c630d800017188d47ada4c3234019f950e85dc6bd9696d3329bd30c976d9af64b6f510a00a000000000000000000020000000203e8000192fd427309e41021c641e0b822ad29bdf87f391b7ea18fe5e661441d7198ce7e98d464b4dd4baeda830871beea83fa5ab8377909444ebfd16ada4f8a7afd2f590003fffe01000000000002232800013aed03e123cfe86e3bd0167fc8beee4298e819b766697aef44888512e2d5e41a1c97630b76e1434da3ad3a63221ba611e96183c57fa2664357f0e2b0ff4573f60003fffe0100000000000000000000', 'created_at' => '2023-12-12T02:30:30.215678512Z', 'updated_at' => '0001-01-01T00:00:00Z', 'snapshot_hash' => '', 'snapshot_at' => '0001-01-01T00:00:00Z', 'snapshot_id' => '', 'senders_hash' => '485d1a0447811fa87434f52ed3a49e8af59540bd8d30aef685fc84a89bd4c7b9', 'senders_threshold' => 1, 'senders' => ['f2a6a584-e242-4da4-aaf5-782bd2995971'], 'signers' => [], 'receivers' => [{ 'members' => ['7ed9292d-7c95-4333-aa48-a8c640064186'], 'members_hash' => 'c3623f8111db2438d9eb05c81d5bd81cc2d0e7fc0ea75d630c735394734c20b0', 'threshold' => 1, 'destination' => '', 'tag' => '', 'withdrawal_hash' => '' }, { 'members' => ['f2a6a584-e242-4da4-aaf5-782bd2995971'], 'members_hash' => '485d1a0447811fa87434f52ed3a49e8af59540bd8d30aef685fc84a89bd4c7b9', 'threshold' => 1, 'destination' => '', 'tag' => '', 'withdrawal_hash' => '' }], 'views' => ['90638928204f5bd25ca021095eb0eeb3d9d22272d5328afe666e5f57db93b103'], 'user_id' => 'f2a6a584-e242-4da4-aaf5-782bd2995971' }

    signed_raw = MixinBot.api.sign_safe_transaction(request:, raw:, utxos:)

    decoded_signed_raw = MixinBot.api.decode_raw_transaction signed_raw

    expect(signed_raw).not_to equal(raw)
    expect(decoded_signed_raw[:signatures]).to be_a(Hash)
    expect(decoded_signed_raw[:signatures]).not_to be_blank
  end
end
