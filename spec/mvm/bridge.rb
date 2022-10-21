# frozen_string_literal: true

require 'spec_helper'

describe MVM::Bridge do
  it 'find or create user' do
    res = MVM.bridge.user '0xF376516D190c8e5f455C299fD191e93Bf4624245'
    expect(res['user']&.[]('user_id')).not_to be_nil
  end

  it 'create extra' do
    res = MVM.bridge.extra receivers: NFO_MTG, threshold: NFO_THRESHOLD, extra: 'test'
    expect(res['extra']).not_to be_nil
  end
end
