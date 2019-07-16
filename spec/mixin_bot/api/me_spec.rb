# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Me do
  it 'can read me' do
    res = MixinBot.api.read_me
    expect(res['data']).not_to be_nil
    expect(res['data']['user_id']).to eq(MixinBot.api.client_id)
  end

  it 'can read assets' do
    res = MixinBot.api.read_assets
    expect(res['data']).not_to be_nil
  end

  it 'can read asset' do
    res = MixinBot.api.read_asset(CNB_ASSET_ID)
    expect(res['data']).not_to be_nil
    expect(res['data']['symbol']).to eq('CNB')
  end

  it 'can read friends' do
    res = MixinBot.api.read_friends
    expect(res['data']).not_to be_nil
  end
end
