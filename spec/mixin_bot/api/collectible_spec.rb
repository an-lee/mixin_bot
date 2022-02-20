# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Collectible do
  # {"type"=>"non_fungible_token", "token_id"=>"abfe580a-1fa0-3237-8c43-52c7de5c80ae", "group"=>"00000000000000000000000000000000", "token"=>"999", "mixin_id"=>"1700941284a95f31b25ec8c546008f208f88eee4419ccdcdbe6e3195e60128ca", "nfo"=>"4e464f0000206c595a1cb880bc7c67b95de7af5b18b09a59461cd097c3fe26c26b2a78c0f354", "meta"=>{"group"=>"Bar", "name"=>"Foo", "description"=>"", "icon_url"=>"", "media_url"=>"", "mime"=>"image/png", "hash"=>""}, "created_at"=>"2021-10-27T05:11:58.748496914Z"}

  it 'read collectible' do
    token = 'abfe580a-1fa0-3237-8c43-52c7de5c80ae'
    # token = '4167b2b9-bd47-380a-95d9-c5f2eb57675b'
    res = MixinBot.api.collectible token

    # puts res['data']
    expect(res['data']).not_to be_nil
  end

  # {"type"=>"non_fungible_output", "user_id"=>"0508a116-1239-4e28-b150-85a8e3e6b400", "output_id"=>"8c3e7291-f29e-3459-98d5-8d7a1f91f662", "token_id"=>"4167b2b9-bd47-380a-95d9-c5f2eb57675b", "transaction_hash"=>"ddcc9974d8264e7970ce02404f8cfdcd2195171c13f16ca4f7149d9d74513232", "output_index"=>0, "amount"=>"1", "senders_threshold"=>1, "senders"=>["7ed9292d-7c95-4333-aa48-a8c640064186"], "receivers_threshold"=>1, "receivers"=>["0508a116-1239-4e28-b150-85a8e3e6b400"], "state"=>"unspent", "created_at"=>"2021-10-27T01:40:12.436602Z", "updated_at"=>"2021-10-27T01:40:12.436602Z", "signed_by"=>"", "signed_tx"=>""}
  it 'read collectibles' do
    res = MixinBot.api.collectibles

    # puts res['data']
    expect(res['data']).not_to be_nil
  end

  it 'create/cancel collectible sign request' do
    collectible = MixinBot.api.collectibles(state: :unspent)['data'].first
    raise 'no unpent collectible' if collectible.nil?

    nfo = MixinBot.api.collectible(collectible['token_id'])['data']['nfo']
    puts collectible
    tx = MixinBot.api.build_collectible_transaction(
      collectible: collectible,
      nfo: nfo,
      receivers: [TEST_UID],
      threshold: 1
    )

    raw = MixinBot.api.sign_raw_transaction tx
    puts '== signing =='
    request = MixinBot.api.create_sign_collectible_request raw
    expect(request['request_id']).not_to be_nil
    puts '== cancelling =='
    r = MixinBot.api.cancel_collectible_request request['request_id'], PIN_CODE
    expect(r).not_to be_nil
  end

  it 'send signed raw transaction' do
    collectible = MixinBot.api.collectibles(state: :signed)['data'].first
    raise 'no signed collectible' if collectible.nil?

    puts '== signed =='
    raw = collectible['signed_tx']
    r = MixinBot.api.send_raw_transaction raw
    expect(r).not_to be_nil
  end

  it 'create mint nft payment' do
    collection = ''
    token_id = 999
    meta = {
      collection: {
        id: collection,
        name: 'TEST_COLLECTION',
        description: 'very cool test',
        icon: {
          hash: 'hash of the collection icon',
          url: 'https://mixin.one/assets/8cb83bab76f849798c8e74e8c6a968d3.png'
        }
      },
      token: {
        id: token_id,
        name: 'No.999 Token',
        description: 'unique token',
        icon: {
          hash: 'hash of the token icon',
          url: 'https://mixin.one/assets/8cb83bab76f849798c8e74e8c6a968d3.png'
        },
        media: {}
      }
    }
    meta[:checksum] = SHA3::Digest::SHA256.hexdigest [meta[:collection][:id], meta[:collection][:name], meta[:token][:id], meta[:token][:name]].join

    memo = MixinBot.api.nft_memo collection, token_id, meta

    payment = MixinBot.api.create_multisig_payment(
      asset_id: XIN_ASSET_ID,
      amount: 0.001,
      memo: memo,
      receivers: NFO_MTG,
      threshold: NFO_THRESHOLD
    )

    # puts payment
    expect(payment['data']).not_to be_nil
  end
end
