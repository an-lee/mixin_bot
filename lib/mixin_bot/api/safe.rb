# frozen_string_literal: true

module MixinBot
  class API
    module Safe
      TX_VERSION = 0x05
      OUTPUT_TYPE_SCRIPT = 0x00
      OUTPUT_TYPE_WITHDRAW_SUBMIT = 0xa1

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
        access_token = kwargs[:access_token]
        order = kwargs[:order] || 'ASC'
        members = kwargs[:members] || [client_id]
        threshold = kwargs[:threshold] || members.length

        members_hash = SHA3::Digest::SHA256.hexdigest(members&.sort&.join)

        path = format(
          '/safe/outputs?limit=%<limit>s&offset=%<offset>s&state=%<state>s&members=%<members_hash>s&threshold=%<threshold>s&order=%<order>s',
          limit: limit,
          offset: offset,
          state: state,
          members_hash: members_hash,
          threshold: threshold,
          order: order
        )
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def create_safe_keys(*payload, access_token: nil)
        raise ArgumentError, 'payload should be an array' unless payload.is_a? Array
        raise ArgumentError, 'payload should not be empty' unless payload.size > 0
        raise ArgumentError, 'invalid payload' unless payload.all?(&->(param) {
          param.has_key?(:receivers) && param.has_key?(:index) })

        payload.each do |param|
          param[:hint] ||= SecureRandom.uuid
        end

        path = '/safe/keys'
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      SAFE_RAW_TRANSACTION_ARGUMENTS = %i[utxos recipients ghosts].freeze
      def build_safe_transaction(**kwargs)
        raise ArgumentError, "#{SAFE_RAW_TRANSACTION_ARGUMENTS.join(', ')} are needed for build safe transaction" unless SAFE_RAW_TRANSACTION_ARGUMENTS.all? { |param| kwargs.keys.include? param }

        utxos = kwargs[:utxos].map(&:with_indifferent_access)
        recipients = kwargs[:recipients].map(&:with_indifferent_access)
        ghosts = kwargs[:ghosts].map(&:with_indifferent_access)

        raise ArgumentError, 'utxos should not be empty' if utxos.size == 0
        raise ArgumentError, 'utxos too many' if utxos.size > 255
        raise ArgumentError, 'recipients too many' if recipients.size > 255

        inputs_sum = utxos.sum(&->(utxo) { utxo['amount'].to_d })
        outputs_sum = recipients.sum(&->(recipient) { recipient['amount'].to_d })
        raise ArgumentError, 'inputs sum not equal outputs sum' unless inputs_sum == outputs_sum

        asset = utxos[0]['asset']
        inputs = []
        utxos.each do |utxo|
          raise ArgumentError, 'utxo asset not match' unless utxo['asset'] == asset

          inputs << {
            hash: utxo['transaction_hash'],
            index: utxo['output_index'],
          }
        end

        outputs = []
        recipients.each_with_index do |recipient, index|
          if recipient['destination']
            outputs << {
              type: OUTPUT_TYPE_WITHDRAW_SUBMIT,
              amount: recipient['amount'],
              withdrawal: {
                address: recipient['destination'],
                tag: recipient['tag'] || '',
              }
            }
          else
            outputs << {
              type: OUTPUT_TYPE_SCRIPT,
              amount: recipient['amount'],
              keys: ghosts[index]['keys'],
              mask: ghosts[index]['mask'],
              script: build_threshold_script(recipient['threshold'])
            }
          end
        end

        {
          version: TX_VERSION,
          asset:,
          inputs:,
          outputs:,
        }
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

      def send_safe_transaction(request_id, raw)
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

      def sign_safe_transaction(**kwargs)
        raw = kwargs[:raw]
        tx = MixinBot::Utils.decode_raw_transaction raw
        utxos = kwargs[:utxos]
        request = kwargs[:request]

        msg = Digest::Blake3.digest [raw].pack('H*')
        spenty = Digest::SHA512.digest private_key[...32]

        y_point = JOSE::JWA::FieldElement.new(
          JOSE::JWA::X25519.clamp_scalar(spenty[...32]).x, 
          JOSE::JWA::Edwards25519Point::L
        )

        tx[:signatures] = {}
        tx[:inputs].each_with_index do |input, index|
          utxo = utxos[index]
          raise ArgumentError, 'utxo not match' unless input['hash'] == utxo['transaction_hash'] && input['index'] == utxo['output_index']

          view = [request['views'][index]].pack('H*')
          x_point = JOSE::JWA::FieldElement.new(
            # https://github.com/potatosalad/ruby-jose/blob/e1be589b889f1e59ac233a5d19a3fa13f1e4b8a0/lib/jose/jwa/x25519.rb#L122C14-L122C48
            OpenSSL::BN.new(view.reverse, 2),
            JOSE::JWA::Edwards25519Point::L
          )

          t_point = x_point + y_point

          pub = (JOSE::JWA::Edwards25519Point.stdbase * t_point.x.to_i).encode
          key = t_point.to_bytes(JOSE::JWA::Edwards25519Point::B)
          key_index = utxo['keys'].index pub.unpack1('H*')

          key_digest = Digest::SHA512.digest key

          msg_digest = Digest::SHA512.digest(key_digest[-32...] + msg)

          z_point = JOSE::JWA::FieldElement.new(
            OpenSSL::BN.new(msg_digest[...64].reverse, 2),
            JOSE::JWA::Edwards25519Point::L
          )

          r_point = JOSE::JWA::Edwards25519Point.stdbase * z_point.x.to_i

          hram_digest = Digest::SHA512.digest(r_point.encode + pub + msg)
          _x_point = JOSE::JWA::FieldElement.new(
            OpenSSL::BN.new(hram_digest[...64].reverse, 2),
            JOSE::JWA::Edwards25519Point::L
          )
          s_point = (_x_point * t_point) + z_point

          sig = r_point.encode + s_point.to_bytes(36)
          tx[:signatures][key_index] = sig.unpack1('H*')
        end

        p tx
        MixinBot::Utils.encode_raw_transaction tx
      end

      def safe_transfer(**kwargs)
        # step 1: select inputs
        # step 2: create ghost keys for outputs(mask & keys)
        # step 3: build transaction
        # step 4: verify transaction
        # step 5: sign transaction
        # step 6: submit transaction
      end

      def build_safe_recipients(**kwargs)
        members = kwargs[:members]
        threshold = kwargs[:threshold]
        amount = kwargs[:amount]

        members = [members] if members.is_a? String
        amount = format('%.8f', amount.to_d.to_r).gsub(/\.?0+$/, '')

        {
          members:,
          threshold:,
          amount:,
          mix_address: build_mix_address(members, threshold)
        }
      end
    end
  end
end
