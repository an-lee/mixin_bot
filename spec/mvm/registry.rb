# frozen_string_literal: true

require 'spec_helper'

describe MVM::Registry do
  it 'get asset contract by asset_id' do
    res = MVM.registry.asset 'c94ac88f-4671-3976-b60a-09064f1811e8'
    expect(res).to eq('0x034a771797a1c8694bc33e1aa89f51d1f828e5a4')
  end

  it 'get user contract by mixin_id' do
    res = MVM.registry.user 'eb15555b-fc93-3b2c-a899-5a87d29422ec'
    expect(res).to eq('0x4d16716bfe976a9c5c31b7c84bc89757edf7b823')
  end
end
