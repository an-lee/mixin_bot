# frozen_string_literal: true

module MixinBot
  class API
    module Payment
      def pay_url(options)
        format(
          'https://mixin.one/pay?recipient=%<recipient_id>s&asset=%<asset>s&amount=%<amount>s&trace=%<trace>s&memo=%<memo>s',
          recipient_id: options[:recipient_id],
          asset: options[:asset_id],
          amount: options[:amount],
          trace: options[:trace],
          memo: options[:memo]
        )
      end

      # https://developers.mixin.one/api/alpha-mixin-network/verify-payment/
      def verify_payment(options)
        path = 'payments'
        payload = {
          asset_id: options[:asset_id],
          opponent_id: options[:recipient_id],
          amount: options[:amount],
          trace_id: options[:trace]
        }

        client.post(path, json: payload)
      end
    end
  end
end
