# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestMessage < Minitest::Test
    def setup
      skip 'No config file found' unless MixinBot.config.valid?
    end

    def test_verify_pin
      res = MixinBot.api.verify_pin(PIN_CODE)

      refute_nil res['data']
    end

    # it 'decrypt encrypted pin_code' do
    def test_decrypt_encrypted_pin
      encrypted_pin = MixinBot.api.encrypt_pin(PIN_CODE)
      decrypted_pin = MixinBot.api.decrypt_pin(encrypted_pin)

      key = MixinBot.utils.decode_key PIN_CODE

      assert_equal decrypted_pin, key[0...decrypted_pin.length]
    end
  end
end
