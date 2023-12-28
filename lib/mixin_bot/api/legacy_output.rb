# frozen_string_literal: true

module MixinBot
  class API
    module LegacyOutput
      def outputs(**kwargs)
        limit = kwargs[:limit] || 100
        offset = kwargs[:offset] || ''
        state = kwargs[:state] || ''
        members = kwargs[:members] || []
        threshold = kwargs[:threshold] || ''
        access_token = kwargs[:access_token]
        members = SHA3::Digest::SHA256.hexdigest(members&.sort&.join)

        path = '/multisigs/outputs'
        params = {
          limit:,
          offset:,
          state:,
          members:,
          threshold:
        }.compact_blank

        client.get path, **params, access_token:
      end
      alias multisigs outputs
      alias multisig_outputs outputs

      def create_output(receivers:, index:, hint: nil, access_token: nil)
        path = '/outputs'
        payload = {
          receivers:,
          index:,
          hint:
        }
        client.post path, **payload, access_token:
      end

      def build_output(receivers:, index:, amount:, threshold:, hint: nil)
        _output = create_output(receivers:, index:, hint:)
        {
          amount: format('%.8f', amount.to_d.to_r),
          script: build_threshold_script(threshold),
          mask: _output['mask'],
          keys: _output['keys']
        }
      end
    end
  end
end
