# frozen_string_literal: true

module MixinBot
  class API
    module Safe
      def safe_register(pin)
        path = '/safe/users'

        key = JOSE::JWA::Ed25519.keypair private_key[...32]
        public_key = key[0].unpack1('H*')

        hex = SHA3::Digest::SHA256.hexdigest client_id
        signature = Base64.urlsafe_encode64 JOSE::JWA::Ed25519.sign([hex].pack('H*'), key[1]), padding: false

        pin_base64 = encrypt_tip_pin pin, 'SEQUENCER:REGISTER:', client_id, public_key

        payload = {
          public_key: public_key,
          signature: signature,
          pin_base64: pin_base64 
        }

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def safe_profile(**options)
        path = '/safe/me'
        access_token = options[:access_token] || access_token('GET', path)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def safe_deposit_entries(chain_id, members, threshold = 1, **options)
        path = '/safe/deposit/entries'
        members = [members] if members.is_a? String
        p members

        payload = {
          members: members,
          threshold: threshold,
          chain_id: chain_id
        }

        access_token = options[:access_token] || access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def safe_outputs(**kwargs)
        limit = kwargs[:limit] || 500
        offset = kwargs[:offset] || ''
        state = kwargs[:state] || ''
        threshold = kwargs[:threshold] || ''
        access_token = kwargs[:access_token]
        order = kwargs[:order] || 'ASC'
        members = kwargs[:members] || []
        members = SHA3::Digest::SHA256.hexdigest(members&.sort&.join)

        path = format(
          '/safe/outputs?limit=%<limit>s&offset=%<offset>s&state=%<state>s&members=%<members>s&threshold=%<threshold>s&order=%<order>s',
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

      def create_safe_key(**kwargs)
        path = '/safe/keys'
        payload = {
          receivers: kwargs[:receivers],
          index: kwargs[:index],
          hint: kwargs[:hint]
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def create_safe_transaction_request(request_id, raw)
        path = '/safe/transaction/requests'
        payload = [{
          request_id: request_id,
          raw: raw
        }]

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def create_safe_transaction(request_id, raw)
        path = '/safe/transactions'
        payload = [{
          request_id: request_id,
          raw: raw
        }]

        access_token = access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def safe_transaction(request_id)
        path = format('/safe/transactions/%<request_id>s', request_id: request_id)

        access_token = access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
    end
  end
end
