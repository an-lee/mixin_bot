require 'spec_helper'

describe "Message" do
  before do
  end

  describe 'message' do
    it "should write msg" do
      conversation_id = MixinBot.api.unique_conversation_id(TEST_UID)
      msg = MixinBot.api.plain_text_message(conversation_id, 'test')
      msg.wont_be_nil
    end

    it "should send msg" do
      conversation_id = MixinBot.api.unique_conversation_id(TEST_UID)
      params = {
        conversation_id: conversation_id,
        category: 'PLAIN_TEXT',
        status: 'SENT',
        message_id: SecureRandom.uuid,
        data: Base64.encode64('test')
      }
      res = MixinBot.api.send(params.to_json)
      res.wont_be_nil
    end
  end
end
