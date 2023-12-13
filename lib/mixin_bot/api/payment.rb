# frozen_string_literal: true

module MixinBot
  class API
    module Payment
      def pay_url(options)
        format(
          'https://mixin.one/pay?recipient=%<recipient_id>s&asset=%<asset>s&amount=%<amount>s&trace=%<trace>s&memo=%<memo>s',
          recipient_id: options[:recipient_id],
          asset: options[:asset_id],
          amount: options[:amount].to_s,
          trace: options[:trace],
          memo: options[:memo]
        )
      end

      # https://developers.mixin.one/api/alpha-mixin-network/verify-payment/
      def verify_payment(options)
        path = 'payments'
        payload = {
          asset_id: options[:asset_id],
          opponent_id: options[:opponent_id],
          amount: options[:amount].to_s,
          trace_id: options[:trace]
        }

        client.post(path, json: payload)
      end

      def safe_pay_url(**kwargs)
        members = kwargs[:members]
        threshold = kwargs[:threshold]
        asset_id = kwargs[:asset_id]
        amount = kwargs[:amount]
        memo = kwargs[:memo] || ''
        trace_id = kwargs[:trace_id] || SecureRandom.uuid

        mix_address = build_mix_address(members, threshold)

        "https://mixin.one/pay/#{mix_address}?amount=#{amount}&asset=#{asset_id}&memo=#{memo}&trace=#{trace_id}"
      end
    end
  end
end
