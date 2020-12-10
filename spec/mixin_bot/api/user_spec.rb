# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::User do
  it 'read user' do
    res = MixinBot.api.read_user(TEST_UID)
    expect(res['data']&.[]('user_id')).to eq(TEST_UID)
  end

  it 'generate rsa key' do
    res = MixinBot.api.generate_rsa_key
    expect(res).to have_key(:public_key)
  end

  it 'generate ed25519 key' do
    res = MixinBot.api.generate_ed25519_key
    expect(res).to have_key(:public_key)
  end

  it 'create user using rsa as default' do
    res = MixinBot.api.create_user('Bot User')
    expect(res['data']&.[]('full_name')).to eq('Bot User')
  end

  it 'create user using ed25519' do
    res = MixinBot.api.create_user('Bot User', key_type: 'Ed25519')
    expect(res['data']&.[]('full_name')).to eq('Bot User')
  end

  it 'create user with provided rsa_key' do
    rsa_key = MixinBot.api.generate_rsa_key
    res = MixinBot.api.create_user('Bot User', rsa_key: rsa_key)
    expect(res[:rsa_key]).to eq(rsa_key)
  end

  it 'search user' do
    res = MixinBot.api.search_user(TEST_MIXIN_ID)
    expect(res['data']&.[]('identity_number')).to eq(TEST_MIXIN_ID)
  end

  it 'read users' do
    res = MixinBot.api.fetch_users([TEST_UID, MixinBot.client_id])
    expect(res['data']).to be_kind_of Array
  end
end
