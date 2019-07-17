# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Withdraw do
  it 'create eth withdraw address' do
    res = MixinBot.api.create_withdraw_address(
      asset_id: ETH_ASSET_ID,
      pin: PIN_CODE,
      public_key: WITHDRAW_ETH_ADDRESS,
      label: 'BigOne'
    )

    expect(res['data']&.[]('public_key')&.downcase).to eq(WITHDRAW_ETH_ADDRESS.downcase)
  end

  it 'create eos withdraw address' do
    res = MixinBot.api.create_withdraw_address(
      asset_id: EOS_ASSET_ID,
      pin: PIN_CODE,
      account_name: WITHDRAW_EOS_ACCOUNT_NAME,
      account_tag: WITHDRAW_EOS_ACCOUNT_TAG,
      label: 'BigOne'
    )

    expect(res['data']&.[]('account_name')).to eq(WITHDRAW_EOS_ACCOUNT_NAME)
  end
  
  it 'get withdraw address' do
    address = MixinBot.api.create_withdraw_address(
      asset_id: ETH_ASSET_ID,
      pin: PIN_CODE,
      public_key: WITHDRAW_ETH_ADDRESS,
      label: 'BigOne'
    )
    address_id = address['data']['address_id']

    res = MixinBot.api.get_withdraw_address(address_id)
    expect(res['data']&.[]('public_key')&.downcase).to eq(WITHDRAW_ETH_ADDRESS.downcase)
  end
  
  it 'delete withdraw address' do
    address = MixinBot.api.create_withdraw_address(
      asset_id: ETH_ASSET_ID,
      pin: PIN_CODE,
      public_key: WITHDRAW_ETH_ADDRESS,
      label: 'BigOne'
    )
    address_id = address['data']['address_id']

    res = MixinBot.api.delete_withdraw_address(address_id, PIN_CODE)
    expect(res).to eq({})
  end
end
