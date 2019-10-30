# frozen_string_literal: true

module MixinBot
  class API
    module Blaze
      def blaze
        access_token = access_token('GET', '/', '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        @blaze ||= Faye::WebSocket::Client.new(
          'wss://blaze.mixin.one/',
          ['Mixin-Blaze-1'],
          headers: { 'Authorization' => authorization },
          ping: 60
        )
      end

      def start_blaze_connnect
        if block_given?
          yield
        else
          blaze.on :open do |_event|
            p [Time.now.to_s, :open]
            blaze.send list_pending_message
          end

          blaze.on :message do |event|
            raw = JSON.parse read_ws_message(event.data)
            p [Time.now.to_s, :message, raw&.[]('action')]

            blaze.send acknowledge_message_receipt(raw['data']['message_id']) unless raw&.[]('data')&.[]('message_id').nil?
          end

          blaze.on :error do |_event|
            p [:error]
          end

          blaze.on :close do |event|
            p [Time.now.to_s, :close, event.code, event.reason]
            start_blaze_connnect
          end
        end
      end
    end
  end
end