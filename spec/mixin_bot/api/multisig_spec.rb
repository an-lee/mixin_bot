# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Multisig do
  it 'read multisigs' do
    # {"data"=>[{"type"=>"multisig_utxo", "user_id"=>"0508a116-1239-4e28-b150-85a8e3e6b400", "utxo_id"=>"684ac1de-cdc5-36f3-9034-ef3b74de0338", "asset_id"=>"965e5c6e-434c-3fa9-b780-c50f43cd955c", "transaction_hash"=>"ed567043fbeab439105570bd77e57fb717dfd24eeef83476f5e0837bb53805cb", "output_index"=>0, "amount"=>"1", "threshold"=>2, "members"=>["0508a116-1239-4e28-b150-85a8e3e6b400", "7ed9292d-7c95-4333-aa48-a8c640064186", "a67c6e87-1c9e-4a1c-b81c-47a9f4f1bff1"], "memo"=>"test for multi sign", "state"=>"unspent", "created_at"=>"2019-12-11T07:32:42.606383Z", "signed_by"=>"", "signed_tx"=>""}]}
    res = MixinBot.api.multisigs

    expect(res['data']).not_to be_nil
  end

  it 'create output' do
    # {"data"=>{"type"=>"ghost_key", "mask"=>"1bb3c2718f22fd6ea9c20655e4246552890ef23d7a07edacd8fa4e1125604260", "keys"=>["9b36d8f4110d6fb82f7d100ae879817cad118835cd91f40dbd1e8e47e60d1b6b", "1fee396d8fdfb858684e81788d2934c5c47bd54ed19cb2a9b295c3c14fe3460a", "d6f5f1d26b0e45a621422a6c01ceca25783d1b12b8dc2a1dd7bbea94f3a7a690"]}}
    res = MixinBot.api.create_output(receivers: MULTI_SIGN_MEMBERS, index: 0)

    expect(res['data']).not_to be_nil
  end

  it 'make a sign request' do
    # {"data"=>{"type"=>"multisig_request", "request_id"=>"11259e74-1b6c-47dc-b08e-d3e4fe54fb74", "user_id"=>"0508a116-1239-4e28-b150-85a8e3e6b400", "asset_id"=>"965e5c6e-434c-3fa9-b780-c50f43cd955c", "amount"=>"0.00000002", "threshold"=>2, "senders"=>["0508a116-1239-4e28-b150-85a8e3e6b400", "7ed9292d-7c95-4333-aa48-a8c640064186", "a67c6e87-1c9e-4a1c-b81c-47a9f4f1bff1"], "receivers"=>["7ed9292d-7c95-4333-aa48-a8c640064186"], "signers"=>[], "memo"=>"test of sign request", "action"=>"sign", "state"=>"initial", "transaction_hash"=>"cb69ca78c0cc7075e326f554c8d76b5b487c0764c2a342ffa7a04a30fd1e36a9", "raw_transaction"=>"85a756657273696f6e01a54173736574c420b9f49cf777dc4d03bc54cd1367eebca319f8603ea1ce18910d09e2c540c630d8a6496e707574739285a448617368c420ed567043fbeab439105570bd77e57fb717dfd24eeef83476f5e0837bb53805cba5496e64657800a747656e65736973c0a74465706f736974c0a44d696e74c085a448617368c42029aed5b74d51f3047d9cb237e6def775fef59447e6d460e1c04656f52312cda1a5496e64657800a747656e65736973c0a74465706f736974c0a44d696e74c0a74f7574707574739285a45479706500a6416d6f756e74d40002a44b65797391c420dcf76afadf2644d5a49e4b7596996b59b29990256522748db638acbe10c1547aa6536372697074c403fffe01a44d61736bc420013e9890ad55148045760ca2a6b68d07bd9f5b9e9908c60b659b44b0a72df51f85a45479706500a6416d6f756e74d6000bebc1fea44b65797393c4208c240bbc7f2bd6ffdf93c3e4f9b1834055e80d7f86da535d400278df1ae72c86c4208ea9946cdd258d963b276087529becd5a0e0eb816d0767e5a654dd09c60866ecc420f555a529f9de021a309b7e24c38cc4ab3ae1fab4954bf89f2bb0fdb2c33a36f4a6536372697074c403fffe02a44d61736bc420dd885c3f365ee90f5cd06fe0ac17a7128bf49b88fc15487549f445a0ce6835eca54578747261c41474657374206f66207369676e2072657175657374", "created_at"=>"1970-01-01T00:03:39+00:03", "code_id"=>"27ceafdc-5c66-42b0-9f5c-61dba9d425d8"}}
    tx = MixinBot.api.build_raw_transaction(
      senders: MULTI_SIGN_MEMBERS.sort,
      receivers: [TEST_UID],
      asset_id: CNB_ASSET_ID,
      asset_mixin_id: CNB_MIXIN_ID,
      threshold: MULTI_SIGN_MEMBERS.size - 1,
      amount: 0.000_000_02,
      memo: 'test of sign request'
    )

    raw = MixinBot.api.sign_raw_transaction tx

    res = MixinBot.api.create_sign_multisig_request(raw, access_token: nil)

    expect(res['data']).not_to be_nil
  end

  it 'create payment code_id' do
    # {"data"=>{"type"=>"payment", "trace_id"=>"9c00bf6d-7713-4ff8-8c1d-4b2330b2d959", "asset_id"=>"965e5c6e-434c-3fa9-b780-c50f43cd955c", "amount"=>"1", "threshold"=>2, "receivers"=>["0508a116-1239-4e28-b150-85a8e3e6b400", "7ed9292d-7c95-4333-aa48-a8c640064186", "a67c6e87-1c9e-4a1c-b81c-47a9f4f1bff1"], "memo"=>"test for multi sign", "created_at"=>"2019-12-11T08:00:26.798147813Z", "status"=>"pending", "code_id"=>"ccf47a70-325e-47ec-b08c-31e075623f3e"}}
    res = MixinBot.api.create_multisig_payment(
      asset_id: CNB_ASSET_ID,
      amount: 1,
      memo: 'test for multi sign',
      receivers: [
        MixinBot.client_id,
        TEST_UID,
        TEST_UID_2
      ],
      threshold: 2
    )

    expect(res['data']).not_to be_nil
  end

  it 'verify payment' do
    # {"data"=>{"type"=>"payment", "trace_id"=>"652415c4-9152-4e28-8028-3c4f48f7f718", "asset_id"=>"965e5c6e-434c-3fa9-b780-c50f43cd955c", "amount"=>"1", "threshold"=>2, "receivers"=>["0508a116-1239-4e28-b150-85a8e3e6b400", "7ed9292d-7c95-4333-aa48-a8c640064186", "a67c6e87-1c9e-4a1c-b81c-47a9f4f1bff1"], "memo"=>"test for multi sign", "created_at"=>"2019-12-11T07:30:57.309776807Z", "status"=>"paid", "code_id"=>"4e4c7f9e-ef12-46d4-a552-4c173f2bb1ca"}}
    res = MixinBot.api.verify_multisig MULTI_SIGN_CODE_ID

    expect(res['data']&.[]('code_id')).to eq(MULTI_SIGN_CODE_ID)
  end
end
