# frozen_string_literal: true

module MixinBot
  class API
    module Collectable
      def collectable(id, access_token: nil)
        path = "/collectables/token/#{id}"
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def collectable_outputs(**kwargs)
        limit = kwargs[:limit] || 100
        offset = kwargs[:offset] || ''
        state = kwargs[:state] || ''
        members = kwargs[:members] || []
        threshold = kwargs[:threshold] || ''
        access_token = kwargs[:access_token]
        members = SHA3::Digest::SHA256.hexdigest(members&.sort&.join)

        path = format(
          '/collectables/outputs?limit=%<limit>s&offset=%<offset>s&state=%<state>s&members=%<members>s&threshold=%<threshold>s',
          limit: limit,
          offset: offset,
          state: state,
          members: members,
          threshold: threshold
        )
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
      alias collectables collectable_outputs

      COLLECTABLE_REQUEST_ACTIONS = %i[sign unlock].freeze
      def create_colletable_request(action, raw, access_token: nil)
        raise ArgumentError, "request action is limited in #{COLLECTABLE_REQUEST_ACTIONS.join(', ')}" unless action.to_sym.in? COLLECTABLE_REQUEST_ACTIONS
        path = '/collectables/requests'
        payload = {
          action: action,
          raw: raw
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def create_sign_colletable_request(raw, access_token: nil)
        create_colletable_output 'sign', raw, access_token
      end

      def create_unlock_colletable_request(raw, access_token: nil)
        create_colletable_output 'unlock', raw, access_token
      end

      def sign_collectable_request(request_id, pin)
        path = format('/collectables/requests/%<request_id>s/sign', request_id: request_id)
        payload = {
          pin: encrypt_pin(pin)
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def unlock_collectable_request(request_id, pin)
        path = format('/collectables/requests/%<request_id>s/unlock', request_id: request_id)
        payload = {
          pin: encrypt_pin(pin)
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def cancel_collectable_request(request_id, pin)
        path = format('/collectables/requests/%<request_id>s/cancel', request_id: request_id)
        payload = {
          pin: encrypt_pin(pin)
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end
    end

    def mint_nft_memo(collection, token_id, meta_data)
      MixinBot::Utils.mint_nft_memo collection, token_id, meta_data
    end
  end
end
