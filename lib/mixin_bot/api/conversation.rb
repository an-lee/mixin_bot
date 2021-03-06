# frozen_string_literal: true

module MixinBot
  class API
    module Conversation
      def conversation(conversation_id)
        path = format('/conversations/%<conversation_id>s', conversation_id: conversation_id)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
      alias read_conversation conversation

      def conversation_by_user_id(user_id)
        conversation_id = unique_conversation_id(user_id)
        read_conversation(conversation_id)
      end
      alias read_conversation_by_user_id conversation_by_user_id

      def create_conversation(category:, conversation_id:, participants:, name: nil, access_token: nil)
        path = '/conversations'
        payload = {
          category: category,
          conversation_id: conversation_id || SecureRandom.uuid,
          name: name,
          participants: participants
        }

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def create_group_conversation(user_ids:, name:, conversation_id: nil, access_token: nil)
        create_conversation(
          category: 'GROUP',
          conversation_id: conversation_id,
          name: name,
          participants: user_ids.map(&->(participant) { { user_id: participant } }),
          access_token: access_token
        )
      end

      def create_contact_conversation(user_id, access_token: nil)
        create_conversation(
          category: 'CONTACT',
          conversation_id: unique_conversation_id(user_id),
          participants: [
            {
              user_id: user_id
            }
          ],
          access_token: access_token
        )
      end

      def update_group_conversation_name(name:, conversation_id:, access_token: nil)
        path = format('/conversations/%<id>s', id: conversation_id)
        payload = {
          name: name
        }

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def update_group_conversation_announcement(announcement:, conversation_id:, access_token: nil)
        path = format('/conversations/%<id>s', id: conversation_id)
        payload = {
          announcement: announcement
        }

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # participants = [{ user_id: "" }]
      def add_conversation_participants(conversation_id:, user_ids:, access_token: nil)
        path = format('/conversations/%<id>s/participants/ADD', id: conversation_id)
        payload = user_ids.map(&->(participant) { { user_id: participant } })

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # participants = [{ user_id: "" }]
      def remove_conversation_participants(conversation_id:, user_ids:, access_token: nil)
        path = format('/conversations/%<id>s/participants/REMOVE', id: conversation_id)
        payload = user_ids.map(&->(participant) { { user_id: participant } })

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def exit_conversation(conversation_id, access_token: nil)
        path = format('/conversations/%<id>s/exit', id: conversation_id)

        access_token ||= access_token('POST', path)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization })
      end

      def rotate_conversation(conversation_id, access_token: nil)
        path = format('/conversations/%<id>s/rotate', id: conversation_id)

        access_token ||= access_token('POST', path)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization })
      end

      # participants = [{ user_id: "", role: "ADMIN" }]
      def update_conversation_participants_role(conversation_id:, participants:, access_token: nil)
        path = format('/conversations/%<id>s/participants/ROLE', id: conversation_id)
        payload = participants

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def unique_uuid(user_id, opponent_id = nil)
        opponent_id ||= client_id
        md5 = Digest::MD5.new
        md5 << [user_id, opponent_id].min
        md5 << [user_id, opponent_id].max
        digest = md5.digest
        digest6 = (digest[6].ord & 0x0f | 0x30).chr
        digest8 = (digest[8].ord & 0x3f | 0x80).chr
        cipher = digest[0...6] + digest6 + digest[7] + digest8 + digest[9..]
        hex = cipher.unpack1('H*')

        format(
          '%<first>s-%<second>s-%<third>s-%<forth>s-%<fifth>s',
          first: hex[0..7],
          second: hex[8..11],
          third: hex[12..15],
          forth: hex[16..19],
          fifth: hex[20..]
        )
      end
      alias unique_conversation_id unique_uuid
    end
  end
end
