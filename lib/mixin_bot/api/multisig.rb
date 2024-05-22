# frozen_string_literal: true

module MixinBot
  class API
    module Multisig
      def create_safe_multisig_request(request_id, raw, access_token: nil)
        path = '/safe/multisigs'
        payload = [{
          request_id:,
          raw:
        }]

        client.post path, *payload, access_token:
      end

      def sign_safe_multisig_request(request_id, raw, access_token: nil)
        path = format('/safe/multisigs/%<request_id>s/sign', request_id:)

        payload = {
          raw:
        }

        client.post path, **payload, access_token:
      end

      def unlock_safe_multisig_request(request_id, access_token: nil)
        path = format('/safe/multisigs/%<request_id>s/unlock', request_id:)

        client.post path, access_token:
      end

      def safe_multisig_request(request_id, access_token: nil)
        path = format('/safe/multisigs/%<request_id>s', request_id:)

        client.get path, access_token:
      end
    end
  end
end
