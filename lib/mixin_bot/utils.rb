# frozen_string_literal: true

require_relative 'utils/address'
require_relative 'utils/crypto'
require_relative 'utils/decoder'
require_relative 'utils/encoder'
require_relative 'utils/nfo'
require_relative 'utils/uuid'
require_relative 'utils/transaction'

module MixinBot
  module Utils
    extend MixinBot::Utils::Address
    extend MixinBot::Utils::Crypto
    extend MixinBot::Utils::Decoder
    extend MixinBot::Utils::Encoder
  end
end
