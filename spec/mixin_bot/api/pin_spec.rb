require 'spec_helper'

describe MixinBot::API::Pin do
  it "verify pin code" do
    res = MixinBot.api.verify_pin(PIN_CODE)
    expect(res['data']).not_to be_nil
  end

  it "decypt encrypted pin_code" do
    encypted_pin = MixinBot.api.encrypt_pin(PIN_CODE)
    decypted_pin = MixinBot.api.decrypt_pin(encypted_pin)
    expect(decypted_pin).to eq(PIN_CODE)
  end
end
