# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestConversation < Minitest::Test
    def setup
      skip 'No config file found' unless MixinBot.config.valid?

      @conversation_id = MixinBot.api.unique_conversation_id(TEST_UID)
      MixinBot.config.debug = true
    end

    def generate_conversation_id
      assert MixinBot.api.unique_conversation_id(TEST_UID) == '204c0633-ef55-38c3-bbf7-4069cd6661bb'
    end

    def test_read_conversation
      r = MixinBot.api.conversation @conversation_id

      assert r['data']['conversation_id'] == @conversation_id
    end

    def test_read_conversation_by_user_id
      r = MixinBot.api.conversation_by_user_id TEST_UID

      assert r['data']['conversation_id'] == @conversation_id
    end

    def test_create_contact_conversation
      r = MixinBot.api.create_contact_conversation TEST_UID

      assert r['data']['conversation_id'] == @conversation_id
    end

    def test_create_group_conversation_and_manage
      # create group
      group = MixinBot.api.create_group_conversation(
        conversation_id: SecureRandom.uuid,
        user_ids: [TEST_UID, TEST_UID_2],
        name: 'Created Group by test'
      )
      refute_nil group['data']['conversation_id']

      # update name
      name = "Updated at #{Time.now}"
      r = MixinBot.api.update_group_conversation_name(
        name:,
        conversation_id: group['data']['conversation_id']
      )
      assert r['data']['name'] == name

      # update announcement
      announcement = 'Announcement: Attention'
      r = MixinBot.api.update_group_conversation_announcement(
        announcement:,
        conversation_id: group['data']['conversation_id']
      )
      assert r['data']['announcement'] == announcement

      # add role
      r = MixinBot.api.update_conversation_participants_role(
        conversation_id: group['data']['conversation_id'],
        participants: [
          { user_id: TEST_UID, role: 'ADMIN' }
        ]
      )
      assert r['data']['participants'].find(&->(user) { user['user_id'] == TEST_UID })['role'] == 'ADMIN'

      # remove role
      r = MixinBot.api.update_conversation_participants_role(
        conversation_id: group['data']['conversation_id'],
        participants: [
          { user_id: TEST_UID, role: '' }
        ]
      )
      assert r['data']['participants'].find(&->(user) { user['user_id'] == TEST_UID })['role'] == ''

      # rotate conversation
      r = MixinBot.api.rotate_conversation group['data']['conversation_id']
      assert r['data']['code_id'] != group['data']['code_id']

      # add participants
      r = MixinBot
          .api
          .remove_conversation_participants(
            conversation_id: group['data']['conversation_id'],
            user_ids: [TEST_UID]
          )
      assert r['data']['participants'].find(&->(user) { user['user_id'] == TEST_UID }).nil?

      # remove participants
      r = MixinBot
          .api
          .add_conversation_participants(
            conversation_id: group['data']['conversation_id'],
            user_ids: [TEST_UID]
          )
      assert r['data']['participants'].find(&->(user) { user['user_id'] == TEST_UID }).present?

      # exit conversation
      r = MixinBot.api.exit_conversation group['data']['conversation_id']
      assert r['data'].nil?
    end
  end
end
