# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::MultiSign do
  it 'read multisigs' do
    # {"data"=>[{"type"=>"multisig_utxo", "user_id"=>"0508a116-1239-4e28-b150-85a8e3e6b400", "utxo_id"=>"684ac1de-cdc5-36f3-9034-ef3b74de0338", "asset_id"=>"965e5c6e-434c-3fa9-b780-c50f43cd955c", "transaction_hash"=>"ed567043fbeab439105570bd77e57fb717dfd24eeef83476f5e0837bb53805cb", "output_index"=>0, "amount"=>"1", "threshold"=>2, "members"=>["0508a116-1239-4e28-b150-85a8e3e6b400", "7ed9292d-7c95-4333-aa48-a8c640064186", "a67c6e87-1c9e-4a1c-b81c-47a9f4f1bff1"], "memo"=>"test for multi sign", "state"=>"unspent", "created_at"=>"2019-12-11T07:32:42.606383Z", "signed_by"=>"", "signed_tx"=>""}]}
    res = MixinBot.api.get_multisigs

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
    res = MixinBot.api.verify_multi_payment MULTI_SIGN_CODE_ID

    expect(res['data']&.[]('code_id')).to eq(MULTI_SIGN_CODE_ID)
  end
end
