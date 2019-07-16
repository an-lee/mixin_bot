# frozen_string_literal: true

module MixinBot
  class API
    module Conversation
      def read_conversation(conversation_id)
        path = format('/conversations/%<conversation_id>s', conversation_id: conversation_id)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def read_conversation_by_user_id(user_id)
        conversation_id = unique_conversation_id(user_id)
        read_conversation(conversation_id)
      end

      def create_contact_conversation(user_id)
        path = '/conversations'
        payload = {
          category: 'CONTACT',
          conversation_id: unique_conversation_id(user_id),
          participants: [
            {
              action: 'ADD',
              role: '',
              user_id: user_id
            }
          ]
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def unique_conversation_id(user_id)
        md5 = Digest::MD5.new
        md5 << [user_id, client_id].min
        md5 << [user_id, client_id].max
        digest = md5.digest
        digest6 = (digest[6].ord & 0x0f | 0x30).chr
        digest8 = (digest[8].ord & 0x3f | 0x80).chr
        cipher = digest[0...6] + digest6 + digest[7] + digest8 + digest[9..-1]
        hex = cipher.unpack1('H*')

        format(
          '%<first>s-%<second>s-%<third>s-%<forth>s-%<fifth>s',
          first: hex[0..7],
          second: hex[8..11],
          third: hex[12..15],
          forth: hex[16..19],
          fifth: hex[20..-1]
        )
      end
    end
  end
end
