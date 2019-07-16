# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Snapshot do
  it 'read public snapshots' do
    res = MixinBot.api.read_snapshots(limit: 5)
    expect(res['data']&.[](0)&.[]('type')).to eq('snapshot')
  end

  # TODO:
  # not verified yet
  # it 'read private snapshots' do
  #   res = MixinBot.api.read_snapshots(limit: 1, private: true)
  #   expect(res['data']&.[](0)&.[]('user_id')).not_to be_nil
  # end
end
