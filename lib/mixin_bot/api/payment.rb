module MixinBot
  class API
    module Payment
      def pay_url(options)
        options = options.with_indifferent_access
        recipient_id = options.fetch('recipient_id')
        asset_id = options.fetch('asset_id')
        amount = options.fetch('amount')
        memo = options.fetch('memo')
        trace = options.fetch('trace')
        url = format('https://mixin.one/pay?recipient=%s&asset=%s&amount=%s&trace=%s&memo=%s', recipient_id, asset_id, amount, trace, memo)
      end

      def verify_payment(options)
        options = options.with_indifferent_access
        recipient_id = options.fetch('recipient_id')
        asset_id = options.fetch('asset_id')
        amount = options.fetch('amount')
        trace = options.fetch('trace')
        path = 'payments'
        payload = {
          asset_id: asset_id,
          opponent_id: recipient_id,
          amount: amount,
          trace_id: trace,
        }
        client.post(path, json: payload)
      end
    end
  end
end
