# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestInvoice < Minitest::Test
    def setup
    end

    def test_decode_invoice
      invoice_string = 'MINAABzAgQHZ6h4KBj1RqG2zMcql6d8Q8lKyI9GcTl2tgoJBk8YEejG0McoJiRCm44N2dGbZZL6Z6h4KBj1RqG2zMcql6d8Q8lKyI9GcTl2tgoJBk8YEejG0McoJiRCm44N2dGbZZL6Z6h4KBj1RqG2zMcql6d8QwJ3LmvvO_9PzJh9Kbr8p01jxtDHKCYkQpuODdnRm2WS-gowLjEyMzQ1Njc4AAlleHRyYSBvbmUBAH7Pn8Sf9NLjZCS45T5nrtjMTp0I18vcp9i9sVPtL83eNVLRFrKdTXKbJDyjsuD5wkPWHc3kE0UNgLgQHV6QM1cKMC4yMzM0NTY3OAAJZXh0cmEgdHdvAgEAAEpfecdoclJMakqBsXQzhYTnkPCfsFnDnPKolN4bPDHGTTpvYA'

      invoice = MixinBot::Invoice.decode(invoice_string)
      puts invoice.inspect

      assert invoice.version, 0
    end
  end
end
