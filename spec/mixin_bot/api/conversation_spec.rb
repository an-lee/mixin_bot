# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Conversation do
  let(:conversation_id) { MixinBot.api.unique_conversation_id(TEST_UID) }

  it 'generate unique conversation id' do
    expect(MixinBot.api.unique_conversation_id(TEST_UID)).to eq('204c0633-ef55-38c3-bbf7-4069cd6661bb')
  end

  it 'read conversation' do
    res = MixinBot.api.read_conversation(conversation_id)
    expect(res['data']&.[]('conversation_id')).to eq(conversation_id)
  end

  it 'read conversation by user_id' do
    res = MixinBot.api.read_conversation_by_user_id(TEST_UID)
    expect(res['data']&.[]('conversation_id')).to eq(conversation_id)
  end

  it 'create coversation' do
    res = MixinBot.api.create_contact_conversation(TEST_UID)
    expect(res['data']&.[]('conversation_id')).to eq(conversation_id)
  end
end
