# frozen_string_literal: true

require 'spec_helper'

describe MVM::Registry do
  it 'get pid' do
    res = MVM.registry.pid
    expect(res).to eq('bd670872-76ce-3263-b933-3aa337e212a4')
  end

  it 'get version' do
    res = MVM.registry.version
    expect(res).to eq(1)
  end

  it 'get asset contract by asset_id' do
    res = MVM.registry.contract_from_asset 'c94ac88f-4671-3976-b60a-09064f1811e8'
    expect(res).to eq('0x034a771797a1c8694bc33e1aa89f51d1f828e5a4')
  end

  it 'get user contract by mixin_id' do
    res = MVM.registry.contract_from_user 'eb15555b-fc93-3b2c-a899-5a87d29422ec'
    expect(res).to eq('0x4d16716bfe976a9c5c31b7c84bc89757edf7b823')
  end

  it 'get asset id by contract' do
    res = MVM.registry.asset_from_contract '0x034a771797a1c8694bc33e1aa89f51d1f828e5a4'
    expect(res).to eq('c94ac88f-4671-3976-b60a-09064f1811e8')
  end

  it 'get user ids by contract' do
    res = MVM.registry.users_from_contract '0x4d16716bfe976a9c5c31b7c84bc89757edf7b823'
    expect(res['members']).to eq(['eb15555b-fc93-3b2c-a899-5a87d29422ec'])
    expect(res['threshold']).to eq(1)
  end

  it 'get user id by contract' do
    res = MVM.registry.user_from_contract '0x4d16716bfe976a9c5c31b7c84bc89757edf7b823'
    expect(res).to eq('eb15555b-fc93-3b2c-a899-5a87d29422ec')
  end
end
