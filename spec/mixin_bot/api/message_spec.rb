# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Message do
  let(:conversation_id) { MixinBot.api.unique_conversation_id(TEST_UID) }

  it 'write msg into bytes' do
    msg = MixinBot.api.plain_text_message(conversation_id, 'test from MixinBot')
    expect(msg).not_to be_nil
  end

  it 'send text msg via HTTP post request' do
    res = MixinBot.api.send_text_message(conversation_id, 'test from MixinBot')
    expect(res['data']).not_to be_nil
    expect(res['data']['type']).to eq('message')
  end
end
