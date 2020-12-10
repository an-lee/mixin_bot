# frozen_string_literal: true

module MixinBot
  class API
    module Blaze
      def blaze
        access_token = access_token('GET', '/', '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        Faye::WebSocket::Client.new(
          format('wss://%<host>s/', host: blaze_host),
          ['Mixin-Blaze-1'],
          headers: { 'Authorization' => authorization },
          ping: 60
        )
      end

      def start_blaze_connect(reconnect: true, &_block)
        ws ||= blaze
        yield if block_given?

        ws.on :open do |event|
          if defined? on_open
            on_open ws, event
          else
            p [Time.now.to_s, :open]
            ws.send list_pending_message
          end
        end

        ws.on :message do |event|
          if defined? on_message
            on_message ws, event
          else
            raw = JSON.parse read_ws_message(event.data)
            p [Time.now.to_s, :message, raw&.[]('action')]

            ws.send acknowledge_message_receipt(raw['data']['message_id']) unless raw&.[]('data')&.[]('message_id').nil?
          end
        end

        ws.on :error do |event|
          if defined? on_error
            on_error ws, event
          else
            p [Time.now.to_s, :error]
          end
        end

        ws.on :close do |event|
          if defined? on_close
            on_close ws, event
          else
            p [Time.now.to_s, :close, event.code, event.reason]
          end

          ws = nil
          start_blaze_connect(&block) if reconnect
        end
      end
    end
  end
end
