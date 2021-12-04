# frozen_string_literal: true

module MixinBot
  class API
    module Transfer
      TRANSFER_ARGUMENTS = %i[asset_id opponent_id amount].freeze
      def create_transfer(pin, options = {})
        raise ArgumentError, "#{TRANSFER_ARGUMENTS.join(', ')} are needed for create transfer" unless TRANSFER_ARGUMENTS.all? { |param| options.keys.include? param }

        asset_id = options[:asset_id]
        opponent_id = options[:opponent_id]
        amount = options[:amount].to_d
        memo = options[:memo]
        trace_id = options[:trace_id] || SecureRandom.uuid
        encrypted_pin = options[:encrypted_pin] || encrypt_pin(pin)

        path = '/transfers'
        payload = {
          asset_id: asset_id,
          opponent_id: opponent_id,
          pin: encrypted_pin,
          amount: format('%.8f', amount.to_r),
          trace_id: trace_id,
          memo: memo
        }

        access_token = options[:access_token]
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def transfer(trace_id, access_token: nil)
        path = format('/transfers/trace/%<trace_id>s', trace_id: trace_id)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
      alias read_transfer transfer
    end
  end
end
