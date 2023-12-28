# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestEncrtypedMessage < Minitest::Test
    def test_encrypt_and_decrypt_message
      recipient_key = JOSE::JWA::Ed25519.keypair
      recipient_session_id = SecureRandom.uuid
      recipient_user_id = SecureRandom.uuid

      sender_key = JOSE::JWA::Ed25519.keypair
      sender_session_id = SecureRandom.uuid
      sender_user_id = SecureRandom.uuid

      sessions = [
        {
          'user_id' => recipient_user_id,
          'session_id' => recipient_session_id,
          'public_key' => Base64.urlsafe_encode64(JOSE::JWA::Ed25519.pk_to_curve25519(recipient_key[0]))
        },
        {
          'user_id' => sender_user_id,
          'session_id' => sender_session_id,
          'public_key' => Base64.urlsafe_encode64(JOSE::JWA::Ed25519.pk_to_curve25519(sender_key[0]))
        }
      ]

      msg = "hello world"

      encoded_msg = Base64.urlsafe_encode64(msg)
      encrypted_msg = MixinBot.api.encrypt_message(encoded_msg, sessions, sk: sender_key[1][0...32], pk: sender_key[0])
      refute_nil encrypted_msg

      decrypted_msg = MixinBot.api.decrypt_message(encrypted_msg, sk: recipient_key[1][0...32], si: recipient_session_id)
      decoded_msg = Base64.urlsafe_decode64(decrypted_msg)
      assert_equal msg, decoded_msg
    end

    def test_send_encrypted_text_message
      recipient_id = TEST_UID
      conversation_id = MixinBot.api.unique_uuid(recipient_id)
      conversation = MixinBot.api.create_contact_conversation recipient_id
      sessions = conversation['participant_sessions'].filter(&->(s) { s['user_id'] == recipient_id })

      r =
        MixinBot
        .api
        .send_encrypted_text_message(
          recipient_id:,
          conversation_id:,
          data: 'Hello world',
          sessions:
        )

      assert_equal r['data']['state'], 'SUCCESS'
    end
  end
end
