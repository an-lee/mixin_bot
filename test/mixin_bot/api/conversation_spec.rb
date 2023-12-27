# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Conversation do
  let(:conversation_id) { MixinBot.api.unique_conversation_id(TEST_UID) }
  let(:group_conversation_id) { 'c92f732d-41ff-47e1-9c72-611327d5f29a' }

  it 'generate unique conversation id' do
    expect(MixinBot.api.unique_conversation_id(TEST_UID)).to eq('204c0633-ef55-38c3-bbf7-4069cd6661bb')
  end

  it 'read conversation' do
    res = MixinBot.api.read_conversation(conversation_id)
    expect(res['data']['conversation_id']).to eq(conversation_id)
  end

  it 'read conversation by user_id' do
    res = MixinBot.api.read_conversation_by_user_id(TEST_UID)
    expect(res['data']['conversation_id']).to eq(conversation_id)
  end

  it 'create contact coversation' do
    res = MixinBot.api.create_contact_conversation(TEST_UID)
    expect(res['data']['conversation_id']).to eq(conversation_id)
  end

  it 'create group conversation' do
    res = MixinBot
          .api
          .create_group_conversation(
            conversation_id: SecureRandom.uuid,
            user_ids: [TEST_UID, TEST_UID_2],
            name: 'Created Group by spec'
          )
    puts res
    expect(res['data']['conversation_id']).not_to be_nil
  end

  it 'update conversation name' do
    name = "Updated at #{Time.now}"
    res = MixinBot
          .api
          .update_group_conversation_name(
            name:,
            conversation_id: group_conversation_id
          )
    expect(res['data']['name']).to eq(name)
  end

  it 'update conversation announcement' do
    announcement = 'Announcement: Attention'
    res = MixinBot
          .api
          .update_group_conversation_announcement(
            announcement:,
            conversation_id: group_conversation_id
          )
    expect(res['data']['announcement']).to eq(announcement)
  end

  it 'update coversation participants role admin' do
    res =
      MixinBot
      .api
      .update_conversation_participants_role(
        conversation_id: group_conversation_id,
        participants: [
          { user_id: TEST_UID, role: 'ADMIN' }
        ]
      )
    expect(res['data']['participants'].find(&->(user) { user['user_id'] == TEST_UID })['role']).to eq('ADMIN')
  end

  it 'update coversation participants role nil' do
    res =
      MixinBot
      .api
      .update_conversation_participants_role(
        conversation_id: group_conversation_id,
        participants: [
          { user_id: TEST_UID, role: '' }
        ]
      )
    expect(res['data']['participants'].find(&->(user) { user['user_id'] == TEST_UID })['role']).to eq('')
  end

  it 'rotate conversation' do
    original_code_id = MixinBot.api.conversation(group_conversation_id)['data']['code_id']
    res = MixinBot
          .api
          .rotate_conversation(group_conversation_id)
    expect(res['data']['code_id']).not_to eq(original_code_id)
  end

  it 'remove conversation participants' do
    res = MixinBot
          .api
          .remove_conversation_participants(
            conversation_id: group_conversation_id,
            user_ids: [TEST_UID]
          )
    expect(res['data']['participants'].find(&->(user) { user['user_id'] == TEST_UID })).to be_nil
  end

  it 'add conversation participants' do
    res = MixinBot
          .api
          .add_conversation_participants(
            conversation_id: group_conversation_id,
            user_ids: [TEST_UID]
          )
    expect(res['data']['participants'].find(&->(user) { user['user_id'] == TEST_UID })).not_to be_nil
  end

  it 'exit conversation' do
    res = MixinBot.api.exit_conversation(group_conversation_id)
    expect(res['data']).to be_nil
  end
end
