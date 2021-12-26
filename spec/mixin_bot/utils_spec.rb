# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::Utils do
  it 'build raw transaction' do
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
    puts native_raw
    signed_raw = MixinBot::Utils.sign_raw_transaction tx

    expect(signed_raw).to eq(native_raw) 
  end

  it 'decode raw transaction' do
    raw = '77770002b9f49cf777dc4d03bc54cd1367eebca319f8603ea1ce18910d09e2c540c630d80004750540f569de3878bd384b1f107d69ce7619a84e29e353530b9d1c5506cf7bc800010000000000002bbab12bf60343dbb1c2a51a743ea6ec619dc3204b5682c31dbbfe766ca23efc00010000000000007e5c45e3abe0e7e8a30a820225564e7abdb2251cc97cacdd8e9f361c26b346d500010000000000008428beada0472e2165ed59fe60ef94ea61dea22a9b797be8de11fcf193d6089200010000000000000002000000010200012bb389442c8ae58eb333ea763cb3247ba34973e8d9141d94ca105f293a571741ccaa1a8b2ac39ba4aeae0a98d0ca587e363c81b6acad91c6f8a1a231d93a69000003fffe010000000000050287f2140c0003c5252b99dfed442cc72b32e654dd361933a02ae7281cf0bdf193b427b62e6ac32cbaea606f0a7c36ce3dc9cb8c6cec31c469664b1325387542352e8bf48d8f87f2c710583cb6f0f897d9c980bc376b47f9912c07438ad122cfbb70dddd61237b850004515bc8b4c31fe73a881d3e35444067363485228a57a4defedeade1bd500003fffe020000001474657374206f66207369676e20726571756573740000'

    native_tx = MixinBot.api.decode_raw_transaction_native raw
    tx = MixinBot.api.decode_raw_transaction raw

    expect(tx).to eq(native_tx)
  end

  it 'encode mint nft memo' do
    collection = ''
    token_id = 204035246287023896153498043217692302767
    meta = {
      group: "Bar",
      name: "Foo", 
      description:  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ",
      icon_url: "https://mixin-images.zeromesh.net/zVDjOxNTQvVsA8h2B4ZVxuHoCF3DJszufYKWpd9duXUSbSapoZadC7_13cnWBqg0EmwmRcKGbJaUpA8wFfpgZA=s128", 
      media_url: "https://mixin-images.zeromesh.net/HvYGJsV5TGeZ-X9Ek3FEQohQZ3fE9LBEBGcOcn4c4BNHovP4fW4YB97Dg5LcXoQ1hUjMEgjbl1DPlKg1TW7kK6XP=s128",
      mime: "image/png", 
      hash: "1973a73d678690c5d004b6d6bfec65483749173617807ebf838a96900a3f6955"
    }

    hash = SHA3::Digest::SHA256.hexdigest meta.to_json

    result = 'TkZPAAEAAAAAAAAAAUPWHc3kE0UNgLgQHV6QM1cUPIwWGhiuLIsU_aEhb_99qIxBm10QAAAAAAAAAAAAAAAAAAAAABCZf8JRU9xKu5V5zW47G52vIN8k7X9uQpyzJLSJkRjT2KmX5tONE1oUM0E7o-TplLgq'

    memo = MixinBot::Utils.nft_memo collection, token_id, hash

    expect(memo).to eq(result)
  end

  it 'decode nft memo' do
    encoded = 'TkZPAAEAAAAAAAAAAUPWHc3kE0UNgLgQHV6QM1cUPIwWGhiuLIsU_aEhb_99qIxBm10QAAAAAAAAAAAAAAAAAAAAABCZf8JRU9xKu5V5zW47G52vIN8k7X9uQpyzJLSJkRjT2KmX5tONE1oUM0E7o-TplLgq'
    memo = {
      prefix: 'NFO',
      version: 0,
      mask: 1,
      chain: '43d61dcd-e413-450d-80b8-101d5e903357',
      class: '3c8c161a18ae2c8b14fda1216fff7da88c419b5d',
      collection: '00000000-0000-0000-0000-000000000000',
      token: 204035246287023896153498043217692302767,
      extra: 'df24ed7f6e429cb324b4899118d3d8a997e6d38d135a1433413ba3e4e994b82a'
    }

    decoed = MixinBot::Utils.decode_nft_memo encoded
    # puts decoed

    expect(decoed).to eq(memo)
  end

  it 'decode & encode mint nft memo' do
    collection = ''
    token_id = 1234
    meta = {
      group: "Bar",
      name: "Foo", 
      description:  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ",
      icon_url: "https://mixin-images.zeromesh.net/zVDjOxNTQvVsA8h2B4ZVxuHoCF3DJszufYKWpd9duXUSbSapoZadC7_13cnWBqg0EmwmRcKGbJaUpA8wFfpgZA=s128", 
      media_url: "https://mixin-images.zeromesh.net/HvYGJsV5TGeZ-X9Ek3FEQohQZ3fE9LBEBGcOcn4c4BNHovP4fW4YB97Dg5LcXoQ1hUjMEgjbl1DPlKg1TW7kK6XP=s128",
      mime: "image/png", 
      hash: "1973a73d678690c5d004b6d6bfec65483749173617807ebf838a96900a3f6955"
    }

    hash = MixinBot::Utils.nft_memo_hash collection, token_id, meta[:hash]
    encoded = MixinBot::Utils.nft_memo collection, token_id, meta[:hash]
    decoded = MixinBot::Utils.decode_nft_memo encoded

    expect(decoded).to eq(hash)
  end
end
