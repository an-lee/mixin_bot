module MixinBot
  class API
    module Conversation
      def read_conversation(conversation_id)
        path = format('/conversations/%s', conversation_id)
        _access_token ||= self.access_token('GET', path, '')
        authorization = format('Bearer %s', _access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def read_conversation_by_user_id(user_id)
        conversation_id = unique_conversation_id(user_id)
        return self.read_conversation(conversation_id)
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
        _access_token ||= self.access_token('POST', path, payload.to_json)
        authorization = format('Bearer %s', _access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def unique_conversation_id(user_id)
        md5 = Digest::MD5.new
        md5 << [user_id, client_id].min
        md5 << [user_id, client_id].max
        digest = md5.digest
        digest_6 = (digest[6].ord & 0x0f | 0x30).chr
        digest_8 = (digest[8].ord & 0x3f | 0x80).chr
        cipher = digest[0...6] + digest_6 + digest[7] + digest_8 + digest[9..-1]
        hex = cipher.unpack('H*').first
        conversation_id = format('%s-%s-%s-%s-%s', hex[0..7], hex[8..11], hex[12..15], hex[16..19], hex[20..-1])
      end
    end
  end
end
