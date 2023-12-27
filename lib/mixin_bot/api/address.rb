# frozen_string_literal: true

module MixinBot
  class API
    module Address
      def safe_deposit_entries(**kwargs)
        path = '/safe/deposit/entries'

        members = [kwargs[:members]] if kwargs[:members].is_a? String

        payload = {
          members:,
          threshold: kwargs[:threshold] || 1,
          chain_id: kwargs[:chain_id]
        }

        client.post path, **payload, access_token: kwargs[:access_token]
      end
    end
  end
end
