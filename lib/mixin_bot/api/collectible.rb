# frozen_string_literal: true

module MixinBot
  class API
    module Collectible
      def collectible(id, access_token: nil)
        path = "/collectibles/tokens/#{id}"
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def collectible_outputs(**kwargs)
        limit = kwargs[:limit] || 100
        offset = kwargs[:offset] || ''
        state = kwargs[:state] || ''
        members = kwargs[:members] || [client_id]
        threshold = kwargs[:threshold] || 1
        access_token = kwargs[:access_token]
        members = SHA3::Digest::SHA256.hexdigest(members&.sort&.join)

        path = format(
          '/collectibles/outputs?limit=%<limit>s&offset=%<offset>s&state=%<state>s&members=%<members>s&threshold=%<threshold>s',
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
      alias collectibles collectible_outputs

      COLLECTABLE_REQUEST_ACTIONS = %i[sign unlock].freeze
      def create_collectible_request(action, raw, access_token: nil)
        raise ArgumentError, "request action is limited in #{COLLECTABLE_REQUEST_ACTIONS.join(', ')}" unless action.to_sym.in? COLLECTABLE_REQUEST_ACTIONS
        path = '/collectibles/requests'
        payload = {
          action: action,
          raw: raw
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def create_sign_collectible_request(raw, access_token: nil)
        create_collectible_output 'sign', raw, access_token
      end

      def create_unlock_collectible_request(raw, access_token: nil)
        create_collectible_output 'unlock', raw, access_token
      end

      def sign_collectible_request(request_id, pin)
        path = format('/collectibles/requests/%<request_id>s/sign', request_id: request_id)
        payload = {
          pin: encrypt_pin(pin)
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def unlock_collectible_request(request_id, pin)
        path = format('/collectibles/requests/%<request_id>s/unlock', request_id: request_id)
        payload = {
          pin: encrypt_pin(pin)
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def cancel_collectible_request(request_id, pin)
        path = format('/collectibles/requests/%<request_id>s/cancel', request_id: request_id)
        payload = {
          pin: encrypt_pin(pin)
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end
    end

    def nft_memo(collection, token_id, meta)
      MixinBot::Utils.nft_memo collection, token_id, meta
    end
  end
end
