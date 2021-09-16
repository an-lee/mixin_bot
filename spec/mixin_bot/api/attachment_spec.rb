# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Attachment do
  it 'create attachments' do
    res = MixinBot.api.create_attachment
    expect(res['data']&.[]('type')).to eq('attachment')
  end

  it 'upload attachments' do
    file = File.open File.expand_path('../../fixtures/Mixin.png', __dir__)
    res = MixinBot.api.upload_attachment(file)
    expect(res['attachment_id']).not_to be_nil
    expect(res['view_url']).not_to be_nil
  end

  it 'read attachments' do
    attachment = MixinBot.api.create_attachment
    attachment_id = attachment['data']&.[]('attachment_id')
    res = MixinBot.api.read_attachment(attachment_id)
    expect(res['data']&.[]('attachment_id')).to eq(attachment_id)
  end
end
