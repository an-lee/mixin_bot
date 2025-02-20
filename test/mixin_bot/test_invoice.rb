# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestInvoice < Minitest::Test
    def setup
      @invoice_address = 'MINAABzAgQHZ6h4KBj1RqG2zMcql6d8Q8lKyI9GcTl2tgoJBk8YEejG0McoJiRCm44N2dGbZZL6Z6h4KBj1RqG2zMcql6d8Q8lKyI9GcTl2tgoJBk8YEejG0McoJiRCm44N2dGbZZL6Z6h4KBj1RqG2zMcql6d8QwJ3LmvvO_9PzJh9Kbr8p01jxtDHKCYkQpuODdnRm2WS-gowLjEyMzQ1Njc4AAlleHRyYSBvbmUBAH7Pn8Sf9NLjZCS45T5nrtjMTp0I18vcp9i9sVPtL83eNVLRFrKdTXKbJDyjsuD5wkPWHc3kE0UNgLgQHV6QM1cKMC4yMzM0NTY3OAAJZXh0cmEgdHdvAgEAAEpfecdoclJMakqBsXQzhYTnkPCfsFnDnPKolN4bPDHGTTpvYA'
      @recipient_address = 'MIX4fwusRK88p5GexHWddUQuYJbKMJTAuBvhudgahRXKndvaM8FdPHS2Hgeo7DQxNVoSkKSEDyZeD8TYBhiwiea9PvCzay1A9Vx1C2nugc4iAmhwLGGv4h3GnABeCXHTwWEto9wEe1MWB49jLzy3nuoM81tqE2XnLvUWv'

      @invoice_entry_one = MixinBot::InvoiceEntry.new(
        trace_id: '772e6bef-3bff-4fcc-987d-29bafca74d63',
        asset_id: 'c6d0c728-2624-429b-8e0d-d9d19b6592fa',
        amount: 0.12345678,
        extra: 'extra one',
        index_references: [],
        hash_references: ['7ecf9fc49ff4d2e36424b8e53e67aed8cc4e9d08d7cbdca7d8bdb153ed2fcdde']
      )

      @invoice_entry_two = MixinBot::InvoiceEntry.new(
        trace_id: '3552d116-b29d-4d72-9b24-3ca3b2e0f9c2',
        asset_id: '43d61dcd-e413-450d-80b8-101d5e903357',
        amount: 0.23345678,
        extra: 'extra two',
        index_references: [0],
        hash_references: ['4a5f79c76872524c6a4a81b174338584e790f09fb059c39cf2a894de1b3c31c6']
      )
    end

    def test_decode_invoice
      invoice = MixinBot::Invoice.new(address: @invoice_address)

      assert_equal invoice.version, 0
      assert_equal invoice.entries.size, 2

      assert_equal invoice.recipient.address, @recipient_address

      assert_equal invoice.entries[0].trace_id, @invoice_entry_one.trace_id
      assert_equal invoice.entries[0].asset_id, @invoice_entry_one.asset_id
      assert_equal invoice.entries[0].amount, @invoice_entry_one.amount
      assert_equal invoice.entries[0].extra, @invoice_entry_one.extra
      assert_equal invoice.entries[0].index_references, @invoice_entry_one.index_references
      assert_equal invoice.entries[0].hash_references, @invoice_entry_one.hash_references

      assert_equal invoice.entries[1].trace_id, @invoice_entry_two.trace_id
      assert_equal invoice.entries[1].asset_id, @invoice_entry_two.asset_id
      assert_equal invoice.entries[1].amount, @invoice_entry_two.amount
      assert_equal invoice.entries[1].extra, @invoice_entry_two.extra
      assert_equal invoice.entries[1].index_references, @invoice_entry_two.index_references
      assert_equal invoice.entries[1].hash_references, @invoice_entry_two.hash_references
    end

    def test_encode_invoice
      invoice = MixinBot::Invoice.new(
        recipient: MixinBot::MixAddress.new(address: @recipient_address),
        entries: [@invoice_entry_one, @invoice_entry_two]
      )

      assert_equal invoice.version, 0
      assert_equal invoice.entries.size, 2

      assert_equal invoice.address, @invoice_address

      assert_equal invoice.entries[0].trace_id, @invoice_entry_one.trace_id
      assert_equal invoice.entries[0].asset_id, @invoice_entry_one.asset_id
      assert_equal invoice.entries[0].amount, @invoice_entry_one.amount
      assert_equal invoice.entries[0].extra, @invoice_entry_one.extra
      assert_equal invoice.entries[0].index_references, @invoice_entry_one.index_references
      assert_equal invoice.entries[0].hash_references, @invoice_entry_one.hash_references

      assert_equal invoice.entries[1].trace_id, @invoice_entry_two.trace_id
      assert_equal invoice.entries[1].asset_id, @invoice_entry_two.asset_id
      assert_equal invoice.entries[1].amount, @invoice_entry_two.amount
      assert_equal invoice.entries[1].extra, @invoice_entry_two.extra
      assert_equal invoice.entries[1].index_references, @invoice_entry_two.index_references
      assert_equal invoice.entries[1].hash_references, @invoice_entry_two.hash_references
    end
  end
end
