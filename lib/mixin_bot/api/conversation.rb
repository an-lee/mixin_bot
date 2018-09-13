module MixinBot
  class API
    module Conversation
      def create_conversation
        path = '/conversations'
        access_token ||= self.access_token('GET', path, '')
        params = {
          category: category,
          conversation_id: conversation_id,
          participants: [
            {
              action: 'ADD',
              role: '',
              user_id: user_id
            }
          ]
        }
      end

      def unique_conversation_id(user_id)
        md5 = Digest::MD5.new
        md5 << user_id
        md5 << client_id
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
