# frozen_string_literal: true

module MixinBot
  class Invoice
    INVOICE_PREFIX = 'MIN'
    INVOICE_VERSION = 0x00

    attr_accessor :version, :recipient, :entries

    def initialize(**params)
      @version = params[:version] || INVOICE_VERSION
      @recipient = params[:recipient]
      @entries = params[:entries] || []
    end

    def encode
    end

    def self.decode(encoded_invoice)
      prefix = encoded_invoice[0..2]
      puts 'prefix', prefix
      raise MixinBot::InvalidInvoiceFormatError, 'invalid invoice prefix' unless prefix == INVOICE_PREFIX

      playload = Base64.urlsafe_decode64(encoded_invoice[3..])
      puts 'playload', playload.size
      raise MixinBot::InvalidInvoiceFormatError, 'invalid invoice playload' if playload.size < 3 + 23 + 1

      playload = playload.bytes
      version = MixinBot.utils.decode_int playload.shift(1)
      puts 'version', version
      raise MixinBot::InvalidInvoiceFormatError, 'invalid invoice version' unless version == INVOICE_VERSION

      # parse recipient
      recipient_size = MixinBot.utils.decode_uint16 playload.shift(2)
      puts 'recipient_size', recipient_size
      recipient_bytes = playload.shift(recipient_size)
      recipient_address = recipient_bytes.pack('C*')
      puts 'recipient_address', recipient_address
      recipient = MixinBot::Utils.parse_mix_address recipient_address
      raise MixinBot::InvalidInvoiceFormatError, 'invalid invoice recipient' unless recipient.present?

      # parse entries
      entries_size = MixinBot.utils.decode_int playload.shift(2)
      entries = []
      entries_size.times do
        invoice, playload = InvoiceEntry.decode(playload)
        entries << invoice
      end

      new(version:, recipient:, entries:)
    end
  end

  class InvoiceEntry
    attr_accessor :trace_id, :asset_id, :amount, :extra, :index_references, :hash_references

    def initialize(**params)
      @trace_id = params[:trace_id]
      @asset_id = params[:asset_id]
      @amount = params[:amount]
      @extra = params[:extra]
      @index_references = params[:index_references]
      @hash_references = params[:hash_references]
    end

    def self.decode(playload)
      trace_id = MixinBot::UUID.new(raw: playload.shift(16)).unpacked
      asset_id = MixinBot::UUID.new(raw: playload.shift(16)).unpacked

      amount_size = MixinBot.utils.decode_uint16 playload.shift(2)
      amount = MixinBot.utils.decode_int playload.shift(amount_size)
      amount = format('%.8f', amount.to_f / 1e8).gsub(/\.?0+$/, '')

      extra_size = MixinBot.utils.decode_int playload.shift(2)
      extra = playload.shift(extra_size).pack('C*')

      references_size = MixinBot.utils.decode_int playload.shift(2)
      index_references = MixinBot.utils.decode_int playload.shift(2)
      hash_references = playload.shift(references_size - 2)

      [new(trace_id:, asset_id:, amount:, extra:, index_references:, hash_references:), playload]
    end

    def encode
      bytes = []

      bytes << MixinBot::UUID.new(raw: trace_id).packed.bytes
      bytes << MixinBot::UUID.new(raw: asset_id).packed.bytes

      amount_bytes = MixinBot.utils.encode_int (amount.to_d * 1e8).round
      bytes += MixinBot.utils.encode_uint16 amount_bytes.size
      bytes += amount_bytes

      extra_bytes = extra.bytes
      bytes += MixinBot.utils.encode_uint16 extra_bytes.size
      bytes += extra_bytes

      index_references_bytes = MixinBot.utils.encode_int index_references
      hash_references_bytes = hash_references.pack('H*')

      bytes += MixinBot.utils.encode_uint16(index_references_bytes.size + hash_references_bytes.size)
      bytes += index_references_bytes
      bytes += hash_references_bytes

      bytes
    end
  end
end
