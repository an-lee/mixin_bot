# frozen_string_literal: true

require 'spec_helper'

describe MixinBot::API::Snapshot do
  it 'read public snapshots' do
    res = MixinBot.api.read_network_snapshots(limit: 5)
    expect(res['data']&.[](0)&.[]('type')).to eq('snapshot')
  end

  it 'read public snapshot' do
    snapshot_id = '9b096575-a0fd-4af1-84eb-ef87963a762d'
    res = MixinBot.api.read_network_snapshot(snapshot_id)
    expect(res['data']&.[]('snapshot_id')).to eq(snapshot_id)
  end

  it 'read private snapshots' do
    res = MixinBot.api.read_snapshots(limit: 1)
    expect(res['data']&.[](0)&.[]('type')).to eq('transfer')
  end
end
