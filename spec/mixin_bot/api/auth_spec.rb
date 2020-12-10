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
end
