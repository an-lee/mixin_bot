# frozen_string_literal: true

module MixinBot
  class API
    module Collectible
      NFT_ASSET_MIXIN_ID = '1700941284a95f31b25ec8c546008f208f88eee4419ccdcdbe6e3195e60128ca'

      def collectible(id, access_token: nil)
        path = "/collectibles/tokens/#{id}"
        client.get path, access_token:
      end

      def collection(id, access_token: nil)
        path = "/collectibles/collections/#{id}"
        client.get path, access_token:
      end

      def collectibles(**kwargs)
        limit = kwargs[:limit] || 100
        offset = kwargs[:offset] || ''
        state = kwargs[:state] || ''

        members = kwargs[:members] || [config.app_id]
        threshold = kwargs[:threshold] || members.length

        members = SHA3::Digest::SHA256.hexdigest(members&.sort&.join)

        access_token = kwargs[:access_token]

        path = '/collectibles/outputs'
        params = {
          limit:,
          offset:,
          state:,
          members:,
          threshold:
        }

        client.get path, **params, access_token:
      end

      COLLECTABLE_REQUEST_ACTIONS = %i[sign unlock].freeze
      def create_collectible_request(action, raw, access_token: nil)
        raise ArgumentError, "request action is limited in #{COLLECTABLE_REQUEST_ACTIONS.join(', ')}" unless COLLECTABLE_REQUEST_ACTIONS.include? action.to_sym

        path = '/collectibles/requests'
        payload = {
          action:,
          raw:
        }
        client.post path, **payload, access_token:
      end

      def create_sign_collectible_request(raw, access_token: nil)
        create_collectible_request 'sign', raw, access_token:
      end

      def create_unlock_collectible_request(raw, access_token: nil)
        create_collectible_request 'unlock', raw, access_token:
      end

      def sign_collectible_request(request_id, pin = nil)
        pin ||= config.pin
        raise ArgumentError, 'pin is needed for sign collectible request' if pin.blank?

        path = format('/collectibles/requests/%<request_id>s/sign', request_id:)
        payload =
          if pin.length > 6
            pin_base64 =  encrypt_tip_pin(pin, 'TIP:COLLECTIBLE:REQUEST:SIGN:', request_id)
            {
              pin_base64:,
            }
          else
            {
              pin: encrypt_pin(pin)
            }
          end
        client.post path, **payload
      end

      def unlock_collectible_request(request_id, pin = nil, access_token: nil)
        pin ||= config.pin
        raise ArgumentError, 'pin is needed for sign collectible request' if pin.blank?

        path = format('/collectibles/requests/%<request_id>s/unlock', request_id:)
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

        client.post path, **payload, access_token:
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
        extra: [kwargs['nfo']].pack('H*'),
        amount: 1,
        asset_mixin_id: NFT_ASSET_MIXIN_ID,
        hint: kwargs['hint']
      )
    end

    def nft_memo(collection, token_id, meta)
      MixinBot.utils.nft_memo collection, token_id, meta
    end
  end
end
