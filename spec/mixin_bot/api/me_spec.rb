# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Me do
  it 'read me' do
    res = MixinBot.api.read_me
    expect(res['data']&.[]('user_id')).to eq(MixinBot.config.app_id)
  end

  it 'read assets' do
    res = MixinBot.api.read_assets
    expect(res['data']).not_to be_nil
  end

  it 'read asset' do
    res = MixinBot.api.read_asset(CNB_ASSET_ID)
    expect(res['data']&.[]('symbol')).to eq('CNB')
  end

  it 'read friends' do
    res = MixinBot.api.read_friends
    expect(res['data']).not_to be_nil
  end

  it 'update me' do
    res = MixinBot.api.update_me(full_name: 'updatedMe')
    expect(res['data']&.[]('full_name')).to eq('updatedMe')

    # rollback the update
    MixinBot.api.update_me(full_name: 'BotForDebug')
  end
end
