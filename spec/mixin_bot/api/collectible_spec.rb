# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Collectible do
  it 'read collectible' do
    token = 'abfe580a-1fa0-3237-8c43-52c7de5c80ae'
    res = MixinBot.api.collectible token

    # puts res['data']
    expect(res['data']).not_to be_nil
  end

  it 'read collectibles' do
    res = MixinBot.api.collectibles

    # puts res['data']
    expect(res['data']).not_to be_nil
  end

  it 'create colletible sign request' do
    collection = ''
    token_id = 999
    meta = {
      collection: {
        id: collection,
        name: "TEST_COLLECTION",
        description: "very cool test",
        icon: {
          hash: "hash of the collection icon",
          url: "https://mixin.one/assets/8cb83bab76f849798c8e74e8c6a968d3.png"
        }
      },
      token: {
        id: token_id,
        name: "No.999 Token",
        description: "unique token",
        icon: {
          hash: "hash of the token icon",
          url: "https://mixin.one/assets/8cb83bab76f849798c8e74e8c6a968d3.png"
        },
        media: {}
      },
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
