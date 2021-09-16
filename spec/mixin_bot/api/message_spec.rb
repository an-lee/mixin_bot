# frozen_string_literal: true

require 'spec_helper'
require 'fastimage'

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

  it 'send post msg via HTTP post request' do
    res = MixinBot.api.send_post_message(
      conversation_id: conversation_id,
      data: <<~POST
        # H1
        ## H2
        ### H3

        Hello World in text.

        ![hello world in image](https://developers.mixin.one/assets/f13631293a7e272401e5d500eb1e4d9c.png)

        [hello world in link](https://ohmy.xin)

        ```ts
        console.log('hello world in ts')
        ```

        ```ruby
        puts 'hello world in Ruby'
        ```

        ```mermaid
        A[module A] --> |call| B{module B}
        B --> |failed| C(throw error)
        B --> |success| D(return)
        ```
      POST
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
        icon_url: 'https://mixin.one/assets/98b586edb270556d1972112bd7985e9e.png',
        title: 'Mixin',
        description: 'A free and lightning fast peer-to-peer transactional network for digital assets.',
        action: 'https://mixin.one'
      }
    )

    expect(res['data']&.[]('conversation_id')).to eq(conversation_id)
  end

  it 'send app card group message' do
    res = MixinBot.api.send_app_button_group_message(
      conversation_id: conversation_id,
      data: [
        {
          label: 'Mixin Website',
          color: '#ABABAB',
          action: 'https://mixin.one'
        },
        {
          label: 'Flowin Websit',
          color: '#1296db',
          action: 'https://flowin.xin'
        }
      ]
    )
    expect(res['data']&.[]('conversation_id')).to eq(conversation_id)
  end

  it 'send a batch of messages' do
    messages = [
      MixinBot.api.plain_text(
        conversation_id: conversation_id,
        recipient_id: TEST_UID,
        data: 'test from MixinBot (1/3)'
      ),
      MixinBot.api.plain_text(
        conversation_id: conversation_id,
        recipient_id: TEST_UID,
        data: 'test from MixinBot (2/3)'
      ),
      MixinBot.api.plain_text(
        conversation_id: conversation_id,
        recipient_id: TEST_UID,
        data: 'test from MixinBot (3/3)'
      )
    ]
    res = MixinBot.api.send_message(messages)

    expect(res).to eq({})
  end

  it 'recall message' do
    message_id = SecureRandom.uuid
    MixinBot.api.send_text_message(
      conversation_id: conversation_id,
      data: 'test from MixinBot',
      message_id: message_id
    )

    res = MixinBot.api.recall_message(message_id,
                                      recipient_id: TEST_UID,
                                      conversation_id: conversation_id)

    expect(res['error']).to be_nil
  end

  it 'send image msg via HTTP post request' do
    file_path = File.expand_path('../../fixtures/Mixin.png', __dir__)

    sizes = FastImage.size file_path
    image_type = FastImage.type file_path

    image = File.open file_path
    attachment = MixinBot.api.upload_attachment(image)

    res = MixinBot.api.send_image_message(
      conversation_id: conversation_id,
      data: {
        attachment_id: attachment['attachment_id'],
        mime_type: "images/#{image_type}",
        size: image.size,
        width: sizes[0],
        height: sizes[1]
      }
    )
    expect(res['conversation_id']).to eq(conversation_id)
  end

  it 'send file msg via HTTP post request' do
    file_path = File.expand_path('../../fixtures/Mixin.png', __dir__)

    file = File.open file_path
    attachment = MixinBot.api.upload_attachment(file)

    res = MixinBot.api.send_file_message(
      conversation_id: conversation_id,
      data: {
        attachment_id: attachment['attachment_id'],
        size: file.size,
        name: file.path.split('/').last
      }
    )
    expect(res['conversation_id']).to eq(conversation_id)
  end
end
