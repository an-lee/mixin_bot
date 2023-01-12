# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Auth do
  it 'generate access_token' do
    access_token = MixinBot.api.access_token('GET', '/', '')
    expect(access_token).not_to be_nil
  end

  it 'generate requet oauth url' do
    url = MixinBot.api.request_oauth
    expect(url).to start_with "https://mixin.one/oauth/authorize?client_id=#{MixinBot.client_id}"
  end

  it 'get authorization data' do
    data = MixinBot.api.authorization_data '0508a116-1239-4e28-b150-85a8e3e6b400'
    expect(data).not_to be_nil
  end

  it 'get authorize code' do
    r = MixinBot.api.authorize_code(
      user_id: '0508a116-1239-4e28-b150-85a8e3e6b400',
      pin: PIN_CODE
    )
    expect(r).not_to be_nil
  end
end
