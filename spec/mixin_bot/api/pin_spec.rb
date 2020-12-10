# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Pin do
  it 'verify pin code' do
    res = MixinBot.api.verify_pin(PIN_CODE)
    expect(res['data']).not_to be_nil
  end

  it 'decrypt encrypted pin_code' do
    encrypted_pin = MixinBot.api.encrypt_pin(PIN_CODE)
    decrypted_pin = MixinBot.api.decrypt_pin(encrypted_pin)
    expect(decrypted_pin).to eq(PIN_CODE)
  end

  it 'update_pin' do
    # avoid pin incorrect because of iterator in concurrent spec
    sleep 1
    res = MixinBot.api.update_pin(old_pin: PIN_CODE, pin: '123456')
    expect(res['data']).not_to be_nil

    # rollback the update
    MixinBot.api.update_pin(old_pin: '123456', pin: PIN_CODE)
  end
end
