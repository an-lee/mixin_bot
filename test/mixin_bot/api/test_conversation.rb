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

    def test_conversation
      r = MixinBot.api.conversation @conversation_id

      assert r['data']['conversation_id'] == @conversation_id
    end

    def test_conversation_by_user_id
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

    def test_generate_group_conversation_id
      owner_id = 'c8cb0ac7-d456-4341-be66-0b143aa09922'
      group_name = 'Mixin Rocks'
      participants = %w[
        f937ca18-d1ff-46f5-99e8-e23fbd6fd5f2
        0e0a20c8-31b8-4093-81b8-9cebd9bc8afc
        8391e472-cdbe-4704-be1f-7d184635b885
        831fdb67-13ed-4dc5-ac64-dda89aeda2bb
        f7ff9dde-18c2-4375-8097-b364068b120e
        088c1e3e-1f07-4065-85b5-6b49b4370d32
      ]
      random_id = '01d21e2c-76f5-4940-8ea0-9b7f21728674'
      expected_group_id = '5dac944e-2037-31b4-bbd9-e5fd3ffe571e'

      group_id = MixinBot.api.generate_group_conversation_id(
        user_ids: participants,
        name: group_name,
        owner_id:,
        random_id:
      )

      assert_equal expected_group_id, group_id
    end
  end
end
