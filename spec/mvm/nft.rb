# frozen_string_literal: true

require 'spec_helper'

describe MVM::Nft do
  it 'read collection from contract' do
    res = MVM.nft.collection_from_contract '0xCe773d418eBCBbA0Dc6601806ED8B9741df83C81'
    expect(res).to eq('dbef5999-fcb1-4f58-b84f-6b7af9694280')
  end

  it 'read contract from collection' do
    res = MVM.nft.contract_from_collection 'dbef5999-fcb1-4f58-b84f-6b7af9694280'
    expect(res).to eq('0xCe773d418eBCBbA0Dc6601806ED8B9741df83C81')
  end

  it 'read owner of NFT' do
    res = MVM.nft.owner_of 'dbef5999-fcb1-4f58-b84f-6b7af9694280', '840'
    expect(res).to eq('0xF376516D190c8e5f455C299fD191e93Bf4624245')
  end

  it 'read owner by contract and index' do
    res = MVM.nft.token_of_owner_by_index '0xCe773d418eBCBbA0Dc6601806ED8B9741df83C81', '0xF376516D190c8e5f455C299fD191e93Bf4624245', 0
    expect(res).to eq(1095)
  end
end
