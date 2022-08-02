# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Message do
  let(:conversation_id) { MixinBot.api.unique_conversation_id(TEST_UID) }

  it 'decrypt message' do
    data = 'AQIAOKrOTLCsxaX/BE+3qcZ9Accz5bwGwrjITGyFZriZp2SDh9ySBwFILqo18AnLh9rvdXBqiNCY/HTRIRec2l+kqeMHyNkWxdBVSLHeZ/R7Ska8XEQQ2IlLzbEozuVxqz6OOn3wPWGTRe26VHCUBo4EUkoANff/8IKOmHSJmGQYzxoKejxXoL4Vg9AyWPAtfP0VmfelBl9nx/2zisgc6D1xkm3WS1ckzKaWUR+PhJq4iH/Fq5zk+ClEo5YVk457rEV80w=='

    plain_data = MixinBot.api.decrypt_message data
    expect(plain_data).to eq(Base64.urlsafe_encode64('Hello'))
  end

  it 'encrypt message' do
    session_ids = [SecureRandom.uuid, SecureRandom.uuid]
    ed25519_keys = [JOSE::JWA::Ed25519.keypair, JOSE::JWA::Ed25519.keypair]
    user_id = '7ed9292d-7c95-4333-aa48-a8c640064186'

    sessions = [
      {
        'user_id' => user_id,
        'session_id' => session_ids.first,
        'public_key' => Base64.urlsafe_encode64(JOSE::JWA::Ed25519.pk_to_curve25519(ed25519_keys[0][0]))
      },
      {
        'user_id' => user_id,
        'session_id' => session_ids.second,
        'public_key' => Base64.urlsafe_encode64(JOSE::JWA::Ed25519.pk_to_curve25519(ed25519_keys[1][0]))
      }
    ]

    plain_text = 'Hello'
    plain_text_base64 = Base64.urlsafe_encode64 plain_text
    encrypted_text = MixinBot.api.encrypt_message(plain_text_base64, sessions)

    decrypted_text = MixinBot.api.decrypt_message(encrypted_text, sk: ed25519_keys[0][1][0...32], si: session_ids.first)

    expect(Base64.urlsafe_decode64(decrypted_text)).to eq(plain_text)
  end

  it 'send encrypt message' do
    recipient_id = '7ed9292d-7c95-4333-aa48-a8c640064186'
    sessions = [
      {
        'type' => 'participant',
        'user_id' => '7ed9292d-7c95-4333-aa48-a8c640064186',
        'session_id' => '8387dc92-0701-482e-aa35-f009cb87daef',
        'public_key' => 'oRboV_-XlVXTL5kPbu8U5pItLCIF6pRRE9ILLwAGdxQ'
      }, {
        'type' => 'participant',
        'user_id' => '7ed9292d-7c95-4333-aa48-a8c640064186',
        'session_id' => '9546b2cb-97ee-48a6-86dd-44bff87855ae',
        'public_key' => 'OKrOTLCsxaX_BE-3qcZ9Accz5bwGwrjITGyFZriZp2Q'
      }
    ]

    r = MixinBot.api.send_encrypted_text_message({
                                                   recipient_id: recipient_id,
                                                   conversation_id: MixinBot.api.unique_conversation_id(recipient_id),
                                                   data: 'Hello world',
                                                   sessions: sessions
                                                 })

    expect(r['data']).not_to be_nil
  end
end
