# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::Utils do
  it 'build raw transaction' do
    # tx = MixinBot.api.build_raw_transaction(
    #   senders: MULTI_SIGN_MEMBERS.sort,
    #   receivers: [TEST_UID],
    #   asset_id: CNB_ASSET_ID,
    #   asset_mixin_id: CNB_MIXIN_ID,
    #   threshold: MULTI_SIGN_MEMBERS.size - 1,
    #   amount: 0.000_000_02,
    #   memo: 'test of sign request'
    # )
    # puts tx

    tx = { 
      'version': 2,
      'asset': "b9f49cf777dc4d03bc54cd1367eebca319f8603ea1ce18910d09e2c540c630d8",
      inputs: [
        {
          hash: "750540f569de3878bd384b1f107d69ce7619a84e29e353530b9d1c5506cf7bc8", 
          index: 1
        },
        {
          hash: "2bbab12bf60343dbb1c2a51a743ea6ec619dc3204b5682c31dbbfe766ca23efc",
          index: 1
        },
        {
          hash: "7e5c45e3abe0e7e8a30a820225564e7abdb2251cc97cacdd8e9f361c26b346d5",
          index: 1
        },
        {
          hash: "8428beada0472e2165ed59fe60ef94ea61dea22a9b797be8de11fcf193d60892",
          index: 1
        }
      ],
      outputs: [
        {
          amount: "0.00000002",
          script: "fffe01",
          mask: "ccaa1a8b2ac39ba4aeae0a98d0ca587e363c81b6acad91c6f8a1a231d93a6900",
          keys: [
            "2bb389442c8ae58eb333ea763cb3247ba34973e8d9141d94ca105f293a571741"
          ]
        },
        {
          amount: "108.70723596",
          script: "fffe02",
          mask: "850004515bc8b4c31fe73a881d3e35444067363485228a57a4defedeade1bd50",
          keys: [
            "c5252b99dfed442cc72b32e654dd361933a02ae7281cf0bdf193b427b62e6ac3",
            "2cbaea606f0a7c36ce3dc9cb8c6cec31c469664b1325387542352e8bf48d8f87",
            "f2c710583cb6f0f897d9c980bc376b47f9912c07438ad122cfbb70dddd61237b"
          ]
        }
      ],
      extra: "74657374206f66207369676e2072657175657374"
    }


    native_raw = MixinBot.api.sign_raw_transaction tx.to_json
    signed_raw = MixinBot::Utils.sign_raw_transaction tx

    expect(signed_raw).to eq(native_raw) 
  end

  it 'build fresh raw transaction' do
    tx = MixinBot.api.build_raw_transaction(
      senders: MULTI_SIGN_MEMBERS.sort,
      receivers: [TEST_UID],
      asset_id: CNB_ASSET_ID,
      asset_mixin_id: CNB_MIXIN_ID,
      threshold: MULTI_SIGN_MEMBERS.size - 1,
      amount: 0.000_000_02,
      memo: 'test sign raw transaction'
    )

    native_raw = MixinBot.api.sign_raw_transaction tx
    signed_raw = MixinBot::Utils.sign_raw_transaction tx

    expect(signed_raw).to eq(native_raw) 
  end
end
