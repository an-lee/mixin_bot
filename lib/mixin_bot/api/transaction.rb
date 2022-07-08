# frozen_string_literal: true

module MixinBot
  class API
    module Transaction
      MULTISIG_TRANSACTION_ARGUMENTS = %i[asset_id receivers threshold amount].freeze
      def create_multisig_transaction(pin, options = {})
        raise ArgumentError, "#{MULTISIG_TRANSACTION_ARGUMENTS.join(', ')} are needed for create multisig transaction" unless MULTISIG_TRANSACTION_ARGUMENTS.all? { |param| options.keys.include? param }

        asset_id = options[:asset_id]
        receivers = options[:receivers]
        threshold = options[:threshold]
        amount = options[:amount].to_d
        memo = options[:memo]
        trace_id = options[:trace_id] || SecureRandom.uuid
        encrypted_pin = options[:encrypted_pin] || encrypt_pin(pin)

        path = '/transactions'
        payload = {
          asset_id: asset_id,
          opponent_multisig: {
            receivers: receivers,
            threshold: threshold
          },
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

      MAINNET_TRANSACTION_ARGUMENTS = %i[asset_id opponent_key amount].freeze
      def create_mainnet_transaction(pin, options = {})
        raise ArgumentError, "#{MAINNET_TRANSACTION_ARGUMENTS.join(', ')} are needed for create main net transactions" unless MAINNET_TRANSACTION_ARGUMENTS.all? { |param| options.keys.include? param }

        asset_id = options[:asset_id]
        opponent_key = options[:opponent_key]
        amount = options[:amount].to_d
        memo = options[:memo]
        trace_id = options[:trace_id] || SecureRandom.uuid
        encrypted_pin = options[:encrypted_pin] || encrypt_pin(pin)

        path = '/transactions'
        payload = {
          asset_id: asset_id,
          opponent_key: opponent_key,
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

      def transactions(**options)
        path = format(
          '/external/transactions?limit=%<limit>s&offset=%<offset>s&asset=%<asset>s&destination=%<destination>s&tag=%<tag>s',
          limit: options[:limit],
          offset: options[:offset],
          asset: options[:asset],
          destination: options[:destination],
          tag: options[:tag]
        )

        client.get path
      end
    end
  end
end
