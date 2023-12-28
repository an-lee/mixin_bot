# frozen_string_literal: true

module MixinBot
  class API
    module Multisig
      def sign_safe_multisig_request(request_id, raw)
        path = format('/safe/multisigs/%<request_id>s/sign', request_id:)

        payload = {
          raw:
        }
        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token:)
        client.post(path, headers: { Authorization: authorization }, json: payload)
      end

      def unlock_safe_multisig_request(request_id)
        path = format('/safe/multisigs/%<request_id>s/unlock', request_id:)

        access_token = access_token('POST', path, '')
        authorization = format('Bearer %<access_token>s', access_token:)
        client.post(path, headers: { Authorization: authorization })
      end

      def safe_multisig_request(request_id)
        path = format('/safe/multisigs/%<request_id>s', request_id:)

        access_token = access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token:)
        client.get(path, headers: { Authorization: authorization })
      end
    end
  end
end
