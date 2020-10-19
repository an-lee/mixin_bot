# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::App do
  it 'read favorite apps' do
    res = MixinBot.api.favorite_apps(MixinBot.client_id)
    expect(res['data']).not_to be_nil
  end

  it 'add favorite app' do
    res = MixinBot.api.add_favorite_app('c1412f68-6152-40ad-a193-f7fadf9328a1')
    expect(res['data']&.[]('type')).to eq('favorite_app')
  end

  it 'remove favorite app' do
    res = MixinBot.api.remove_favorite_app('c1412f68-6152-40ad-a193-f7fadf9328a1')
    expect(res).to eq({})
  end
end
