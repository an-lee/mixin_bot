# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestAddress < Minitest::Test
    BURNING_ADDRESS = 'XIN8b7CsqwqaBP7576hvWzo7uDgbU9TB5KGU4jdgYpQTi2qrQGpBtrW49ENQiLGNrYU45e2wwKRD7dEUPtuaJYps2jbR4dH'

    def setup
    end

    def test_burning_address
      assert MixinBot.utils.burning_address == BURNING_ADDRESS
    end
  end
end
