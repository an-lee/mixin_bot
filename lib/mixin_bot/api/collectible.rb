# frozen_string_literal: true

module MixinBot
  class API
    module Collectible
      NFT_ASSET_MIXIN_ID = '1700941284a95f31b25ec8c546008f208f88eee4419ccdcdbe6e3195e60128ca'

      def collectible(id, access_token: nil)
        path = "/collectibles/tokens/#{id}"
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def collection(id, access_token: nil)
        path = "/collectibles/collections/#{id}"
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
        raise ArgumentError, "request action is limited in #{COLLECTABLE_REQUEST_ACTIONS.join(', ')}" unless COLLECTABLE_REQUEST_ACTIONS.include? action.to_sym

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
        create_collectible_request 'sign', raw, access_token: access_token
      end

      def create_unlock_collectible_request(raw, access_token: nil)
        create_collectible_request 'unlock', raw, access_token: access_token
      end

      def sign_collectible_request(request_id, pin)
        path = format('/collectibles/requests/%<request_id>s/sign', request_id: request_id)
        payload = 
          if pin.length > 6
            {
              pin_base64: encrypt_tip_pin(pin, 'TIP:COLLECTIBLE:REQUEST:SIGN:', request_id)
            }
          else
            {
              pin: encrypt_pin(pin)
            }
          end
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def unlock_collectible_request(request_id, pin)
        path = format('/collectibles/requests/%<request_id>s/unlock', request_id: request_id)
        payload = 
          if pin.length > 6
            {
              pin_base64: encrypt_tip_pin(pin, 'TIP:COLLECTIBLE:REQUEST:UNLOCK:', request_id)
            }
          else
            {
              pin: encrypt_pin(pin)
            }
          end
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end
    end

    # collectible = {
    #   type: 'non_fungible_output',
    #   user_id: '',
    #   output_id: '',
    #   token_id: '',
    #   transaction_hash: '',
    #   output_index: '',
    #   amount: 1,
    #   senders: [],
    #   sender_threshold: 1,
    #   receivers: [],
    #   receivers_threshold: 1,
    #   state: 'unspent'
    # }
    COLLECTIBLE_TRANSACTION_ARGUMENTS = %i[collectible nfo receivers receivers_threshold].freeze
    def build_collectible_transaction(**kwargs)
      raise ArgumentError, "#{COLLECTIBLE_TRANSACTION_ARGUMENTS.join(', ')} are needed for build collectible transaction" unless COLLECTIBLE_TRANSACTION_ARGUMENTS.all? { |param| kwargs.keys.include? param }

      kwargs = kwargs.with_indifferent_access
      collectible = kwargs['collectible']
      raise 'collectible is spent' if collectible['state'] == 'spent'

      build_raw_transaction(
        utxos: [collectible],
        senders: collectible['receivers'],
        senders_threshold: collectible['receivers_threshold'],
        receivers: kwargs['receivers'],
        receivers_threshold: kwargs['receivers_threshold'],
        extra: kwargs['nfo'],
        amount: 1,
        asset_mixin_id: NFT_ASSET_MIXIN_ID,
        access_token: kwargs['access_token'],
        hint: kwargs['hint']
      )
    end

    def nft_memo(collection, token_id, meta)
      MixinBot::Utils.nft_memo collection, token_id, meta
    end
  end
end
