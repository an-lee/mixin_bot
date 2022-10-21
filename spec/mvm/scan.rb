# frozen_string_literal: true

require 'spec_helper'

describe MVM::Scan do
  it 'read tokens' do
    res = MVM.scan.tokens '0xF376516D190c8e5f455C299fD191e93Bf4624245'
    expect(res).not_to be_nil
  end
end
