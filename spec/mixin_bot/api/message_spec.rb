# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Message do
  let(:conversation_id) { MixinBot.api.unique_conversation_id(TEST_UID) }

  it 'write msg into bytes' do
    params = MixinBot.api.plain_text(conversation_id: conversation_id, data: 'test from MixinBot')
    msg = MixinBot.api.write_ws_message(params: params)
    expect(msg).not_to be_nil
  end

  it 'send text msg via HTTP post request' do
    res = MixinBot.api.send_text_message(
      conversation_id: conversation_id, 
      data: 'test from MixinBot'
    )
    expect(res['data']&.[]('conversation_id')).to eq(conversation_id)
  end

  it 'quote a message' do
    res = MixinBot.api.send_text_message(
      conversation_id: conversation_id, 
      data: 'test from MixinBot'
    )
    message_id = res['data']&.[]('message_id')
    quoted_res = 
      MixinBot.api.send_text_message(
        conversation_id: conversation_id, 
        data: 'quote the last message', 
        quote_message_id: message_id
      )
    expect(quoted_res['data']&.[]('conversation_id')).to eq(conversation_id)
  end

  it 'send contact message' do
    res = MixinBot.api.send_contact_message(
      conversation_id: conversation_id,
      data: {
        user_id: TEST_UID
      }
    )
    expect(res['data']&.[]('conversation_id')).to eq(conversation_id)
  end

  it 'send app card message' do
    res = MixinBot.api.send_app_card_message(
      conversation_id: conversation_id,
      data: {
        icon_url: "https://mixin.one/assets/98b586edb270556d1972112bd7985e9e.png", 
        title: "Mixin", 
        description: "A free and lightning fast peer-to-peer transactional network for digital assets.", 
        action: "https://mixin.one"
      }
    )

    expect(res['data']&.[]('conversation_id')).to eq(conversation_id)
  end
  

  it 'send app card group message' do
    res = MixinBot.api.send_app_button_group_message(
      conversation_id: conversation_id,
      data: [
        {
          label: "Mixin Website", 
          color: "#ABABAB", 
          action: "https://mixin.one"
        },
        {
          label: "Flowin Websit", 
          color: "#1296db", 
          action: "https://flowin.xin"
        }
      ]
    )
    expect(res['data']&.[]('conversation_id')).to eq(conversation_id)
  end
end
