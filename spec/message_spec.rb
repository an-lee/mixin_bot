require 'spec_helper'

describe "Message" do
  before do
    @conversation_id = MixinBot.api.unique_conversation_id(TEST_UID)
  end

  describe 'message' do
    it "should write msg" do
      msg = MixinBot.api.plain_text_message(@conversation_id, 'test')
      msg.wont_be_nil
    end

    it "should send text msg" do
      res = MixinBot.api.send_text_message(@conversation_id, 'test')
      res['data'].wont_be_nil
      res['data']['type'].must_equal 'message'
    end
  end
end
