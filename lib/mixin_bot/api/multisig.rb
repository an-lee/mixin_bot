# frozen_string_literal: true

module MixinBot
  class API
    module Multisig
      MULTISIG_REQUEST_ACTIONS = %i[sign unlock].freeze
      def create_multisig_request(action, raw, access_token: nil)
        raise ArgumentError, "request action is limited in #{MULTISIG_REQUEST_ACTIONS.join(', ')}" unless MULTISIG_REQUEST_ACTIONS.include? action.to_sym

        path = '/multisigs/requests'
        payload = {
          action: action,
          raw: raw
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # transfer from the multisig address
      def create_sign_multisig_request(raw, access_token: nil)
        create_multisig_request 'sign', raw, access_token: access_token
      end

      # transfer from the multisig address
      # create a request for unlock a multi-sign
      def create_unlock_multisig_request(raw, access_token: nil)
        create_multisig_request 'unlock', raw, access_token: access_token
      end

      def sign_multisig_request(request_id, pin)
        path = format('/multisigs/requests/%<request_id>s/sign', request_id: request_id)
        payload = {
          pin: encrypt_pin(pin)
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def unlock_multisig_request(request_id, pin)
        path = format('/multisigs/requests/%<request_id>s/unlock', request_id: request_id)
        payload = {
          pin: encrypt_pin(pin)
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def cancel_multisig_request(request_id, pin)
        path = format('/multisigs/requests/%<request_id>s/cancel', request_id: request_id)
        payload = {
          pin: encrypt_pin(pin)
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # pay to the multisig address
      # used for create multisig payment code_id
      def create_multisig_payment(**kwargs)
        path = '/payments'
        payload = {
          asset_id: kwargs[:asset_id],
          amount: format('%.8f', kwargs[:amount].to_d.to_r),
          trace_id: kwargs[:trace_id] || SecureRandom.uuid,
          memo: kwargs[:memo],
          opponent_multisig: {
            receivers: kwargs[:receivers],
            threshold: kwargs[:threshold]
          }
        }
        access_token = kwargs[:access_token]
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def verify_multisig(code_id, access_token: nil)
        path = format('/codes/%<code_id>s', code_id: code_id)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
    end
  end
end
