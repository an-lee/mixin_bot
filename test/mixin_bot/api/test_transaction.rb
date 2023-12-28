# frozen_string_literal: true

require 'test_helper'

module MixinBot
  class TestTransaction < Minitest::Test
    def setup
      skip 'No config file found' unless MixinBot.config.valid?
    end
  end
end
