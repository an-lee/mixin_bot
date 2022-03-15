# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::Utils::Nfo do
  it 'build mint memo' do
    nfo = described_class.new(
      collection: '4d6d5171-de60-4dfa-bbca-8072b2df87d8', 
      token: 69, 
      extra: 'ff20cfcd4be747a165ec26f177b9b5ae6878eb9907434f4d936d0bef76064b4a'
    )

    memo = 'TkZPAAEAAAAAAAAAAUPWHc3kE0UNgLgQHV6QM1cUPIwWGhiuLIsU_aEhb_99qIxBm10QTW1Rcd5gTfq7yoByst-H2AFFIP8gz81L50ehZewm8Xe5ta5oeOuZB0NPTZNtC-92BktK'

    nfo.encode

    expect(nfo.mint_memo).to eq(memo)
  end

  it 'decode memo' do
    memo = 'TkZPAAEAAAAAAAAAAUPWHc3kE0UNgLgQHV6QM1cUPIwWGhiuLIsU_aEhb_99qIxBm10QTW1Rcd5gTfq7yoByst-H2AFFIP8gz81L50ehZewm8Xe5ta5oeOuZB0NPTZNtC-92BktK'
    extra = 'ff20cfcd4be747a165ec26f177b9b5ae6878eb9907434f4d936d0bef76064b4a'

    nfo = described_class.new memo: memo

    nfo.decode

    expect(nfo.extra).to eq(extra)
  end

  it 'decode hex' do
    hex = '4e464f0001000000000000000143d61dcde413450d80b8101d5e903357143c8c161a18ae2c8b14fda1216fff7da88c419b5d100000000000000000000000000000000010a1acad756a3a4cb7ace88b750e2d82e620217fdcd1febd5f60a541ae3d91abd14bc00c3ea0004e767ed49b6cfec9c564a3'
    extra = '217fdcd1febd5f60a541ae3d91abd14bc00c3ea0004e767ed49b6cfec9c564a3'

    nfo = described_class.new hex: hex

    nfo.decode
    p nfo

    expect(nfo.extra).to eq(extra)
  end
end