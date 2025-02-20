# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestAddress < Minitest::Test
    def setup
      @burning_address = 'XIN8b7CsqwqaBP7576hvWzo7uDgbU9TB5KGU4jdgYpQTi2qrQGpBtrW49ENQiLGNrYU45e2wwKRD7dEUPtuaJYps2jbR4dH'
    end

    def test_encode_mix_address
      mix_address = MixinBot::MixAddress.new(
        members: [TEST_UID],
        threshold: 1
      )
      assert_equal mix_address.address, 'MIX3QEezkMEfKTnofT28SBMW6MftV3WSRF'
      assert_equal mix_address.uuid_members, [TEST_UID]
      assert_equal mix_address.xin_members, []
      assert_equal mix_address.threshold, 1
    end

    def test_decode_mix_address
      mix_address = MixinBot::MixAddress.new(address: 'MIX3QEezkMEfKTnofT28SBMW6MftV3WSRF')
      assert_equal mix_address.address, 'MIX3QEezkMEfKTnofT28SBMW6MftV3WSRF'
      assert_equal mix_address.uuid_members, [TEST_UID]
      assert_equal mix_address.xin_members, []
      assert_equal mix_address.threshold, 1
    end

    def test_members_order_do_not_affect_mix_address
      mix_address = MixinBot::MixAddress.new(
        members: [TEST_UID, TEST_UID_2],
        threshold: 1
      )
      mix_address2 = MixinBot::MixAddress.new(
        members: [TEST_UID_2, TEST_UID],
        threshold: 1
      )
      assert_equal mix_address.address, mix_address2.address
    end

    def test_burning_address
      assert_equal MixinBot::MainAddress.burning_address.address, @burning_address
    end

    def test_decode_main_address
      address = 'XIN8L6RQuLGR92XLJpN9YeXermg5jAqLQbZnD8DAdovAg1hmB2FP'
      public_key = Base64.urlsafe_decode64('EKRPniKZqVHyj-fq2HrdcQe1rsBVV9xKQKphpW18lds')
      main_address = MixinBot::MainAddress.new(address:)
      assert_equal main_address.public_key, public_key
    end

    def test_encode_and_decode_main_address
      address = 'XIN8L6RQuLGR92XLJpN9YeXermg5jAqLQbZnD8DAdovAg1hmB2FP'
      public_key = Base64.urlsafe_decode64('EKRPniKZqVHyj-fq2HrdcQe1rsBVV9xKQKphpW18lds')

      main_address = MixinBot::MainAddress.new(public_key:)
      assert_equal main_address.address, address
    end
  end
end
