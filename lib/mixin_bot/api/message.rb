# frozen_string_literal: false

module MixinBot
  class API
    # https://developers.mixin.one/api/beta-mixin-message/websocket-messages/
    module Message
      def list_pending_message
        write_ws_message(action: 'LIST_PENDING_MESSAGES', params: {})
      end

      def acknowledge_message_receipt(message_id)
        params = {
          message_id:,
          status: 'READ'
        }
        write_ws_message(action: 'ACKNOWLEDGE_MESSAGE_RECEIPT', params:)
      end

      def plain_text(options)
        options.merge!(category: 'PLAIN_TEXT')
        base_message_params(options)
      end

      def plain_post(options)
        options.merge!(category: 'PLAIN_POST')
        base_message_params(options)
      end

      def plain_image(options)
        options.merge!(category: 'PLAIN_IMAGE')
        base_message_params(options)
      end

      def plain_data(options)
        options.merge!(category: 'PLAIN_DATA')
        base_message_params(options)
      end

      def plain_sticker(options)
        options.merge!(category: 'PLAIN_STICKER')
        base_message_params(options)
      end

      def plain_contact(options)
        options.merge!(category: 'PLAIN_CONTACT')
        base_message_params(options)
      end

      def plain_audio(options)
        options.merge!(category: 'PLAIN_AUDIO')
        base_message_params(options)
      end

      def plain_video(options)
        options.merge!(category: 'PLAIN_VIDEO')
        base_message_params(options)
      end

      def app_card(options)
        options.merge!(category: 'APP_CARD')
        base_message_params(options)
      end

      def app_button_group(options)
        options.merge!(category: 'APP_BUTTON_GROUP')
        base_message_params(options)
      end

      def recall_message_params(message_id, options)
        raise 'recipient_id is required!' if options[:recipient_id].nil?

        options.merge!(
          category: 'MESSAGE_RECALL',
          data: {
            message_id:
          }
        )
        base_message_params(options)
      end

      # base format of message params
      def base_message_params(options)
        data = options[:data].is_a?(String) ? options[:data] : options[:data].to_json
        {
          conversation_id: options[:conversation_id],
          recipient_id: options[:recipient_id],
          representative_id: options[:representative_id],
          category: options[:category],
          status: 'SENT',
          quote_message_id: options[:quote_message_id],
          message_id: options[:message_id] || SecureRandom.uuid,
          data: Base64.encode64(data)
        }.compact
      end

      # read the gzipped message form websocket
      def ws_message(data)
        data = data.pack('c*') if data.is_a?(Array)
        raise MixinBot::ArgumentError, 'data should be String or Array of integer' unless data.is_a?(String)

        io = StringIO.new(data, 'rb')
        gzip = Zlib::GzipReader.new io
        msg = gzip.read
        gzip.close

        msg
      end

      # gzip the message for websocket
      def write_ws_message(params:, action: 'CREATE_MESSAGE')
        msg = {
          id: SecureRandom.uuid,
          action:,
          params:
        }.to_json

        io = StringIO.new 'wb'
        gzip = Zlib::GzipWriter.new io
        gzip.write msg
        gzip.close
        io.string.unpack('c*')
      end

      # use HTTP to send message
      def send_text_message(options)
        send_message plain_text(options)
      end

      def send_image_message(options)
        send_message plain_image(options)
      end

      def send_file_message(options)
        send_message plain_data(options)
      end

      def send_post_message(options)
        send_message plain_post(options)
      end

      def send_contact_message(options)
        send_message plain_contact(options)
      end

      def send_app_card_message(options)
        send_message app_card(options)
      end

      def send_app_button_group_message(options)
        send_message app_button_group(options)
      end

      def recall_message(message_id, options)
        send_message [recall_message_params(message_id, options)]
      end

      def send_plain_messages(messages)
        send_message messages
      end

      # http post request
      def send_message(payload)
        path = '/messages'

        if payload.is_a? Hash
          client.post path, **payload
        elsif payload.is_a? Array
          client.post path, *payload
        end
      end
    end
  end
end
