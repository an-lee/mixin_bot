# frozen_string_literal: false

module MixinBot
  class API
    module Message
      def send_text_message(conversation_id, text, message_id: nil)
        payload = {
          conversation_id: conversation_id,
          category: 'PLAIN_TEXT',
          status: 'SENT',
          message_id: message_id || SecureRandom.uuid,
          data: Base64.encode64(text)
        }
        send_message payload
      end

      def send_message(payload)
        path = '/messages'
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def list_pending_message
        write_message('LIST_PENDING_MESSAGES', {})
      end

      def acknowledge_message_receipt(message_id)
        params = {
          message_id: message_id,
          status: 'READ'
        }
        write_message('ACKNOWLEDGE_MESSAGE_RECEIPT', params)
      end

      def plain_text_message(conversation_id, text)
        encoded_text = Base64.encode64 text

        params = {
          conversation_id: conversation_id,
          category: 'PLAIN_TEXT',
          status: 'SENT',
          message_id: SecureRandom.uuid,
          data: encoded_text
        }

        write_message('CREATE_MESSAGE', params)
      end

      def app_card_message(conversation_id, options)
        encoded_data = Base64.encode64 options.to_json
        params = {
          conversation_id: conversation_id,
          category: 'APP_CARD',
          status: 'SENT',
          message_id: SecureRandom.uuid,
          data: encoded_data
        }

        write_message('CREATE_MESSAGE', params)
      end

      def app_button_group_message(conversation_id, recipient_id, options)
        encoded_data = Base64.encode64 options.to_json

        params = {
          conversation_id: conversation_id,
          recipient_id: recipient_id,
          category: 'APP_BUTTON_GROUP',
          status: 'SENT',
          message_id: SecureRandom.uuid,
          data: encoded_data
        }

        write_message('CREATE_MESSAGE', params)
      end

      def read_message(data)
        io = StringIO.new(data.pack('c*'), 'rb')
        gzip = Zlib::GzipReader.new io
        msg = gzip.read
        gzip.close

        msg
      end

      def write_message(action, params)
        msg = {
          id: SecureRandom.uuid,
          action: action,
          params: params
        }.to_json

        io = StringIO.new 'wb'
        gzip = Zlib::GzipWriter.new io
        gzip.write msg
        gzip.close
        io.string.unpack('c*')
      end
    end
  end
end
