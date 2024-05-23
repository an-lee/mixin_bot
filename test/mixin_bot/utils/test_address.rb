# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestAddress < Minitest::Test
    BURNING_ADDRESS = 'XIN8b7CsqwqaBP7576hvWzo7uDgbU9TB5KGU4jdgYpQTi2qrQGpBtrW49ENQiLGNrYU45e2wwKRD7dEUPtuaJYps2jbR4dH'

    def setup
    end

    def test_utils_burning_address
      assert MixinBot.utils.burning_address == BURNING_ADDRESS
    end

    def test_utils_parse_mix_address
      user_id = TEST_UID
      mix_address = MixinBot.utils.build_mix_address(
        members: [user_id],
        threshold: 1
      )
      address = MixinBot.utils.parse_mix_address mix_address

      assert address[:members] = [user_id]
      assert address[:threshold] == 1
    end
  end
end
