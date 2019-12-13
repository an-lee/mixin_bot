# frozen_string_literal: true

module MixinBot
  class Schmoozer < Schmooze::Base
    dependencies transaction: './transaction'

    method :build_transaction, <<~JS
      function(tx) {
        return mixinGo.buildTransaction(tx);
      }
    JS
  end
end
