require 'spec_helper'

describe 'me' do
  before do
  end

  describe 'me' do
    it 'can read me' do
      res = MixinBot.api.read_me
      res['data'].wont_be_nil
      res['data']['user_id'].must_equal MixinBot.api.client_id
    end

    it 'can read assets' do
      res = MixinBot.api.read_assets
      res['data'].wont_be_nil
    end

    it 'can read asset' do
      res = MixinBot.api.read_asset(CNB_ASSET_ID)
      res['data'].wont_be_nil
      res['data']['symbol'].must_equal 'CNB'
    end
    
    it 'can read friends' do
      res = MixinBot.api.read_friends
      res['data'].wont_be_nil
    end
  end
end
