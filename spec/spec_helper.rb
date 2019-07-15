require 'minitest/autorun'
require 'mixin_bot'
require 'yaml'

CONFIG = YAML.load_file("#{File.dirname __FILE__}/config.yml")
PIN_CODE = CONFIG['pin_code'].freeze
TEST_UID = '7ed9292d-7c95-4333-aa48-a8c640064186'.freeze
CNB_ASSET_ID = '965e5c6e-434c-3fa9-b780-c50f43cd955c'

MixinBot.client_id = CONFIG['client_id']
MixinBot.client_secret = CONFIG['client_secret']
MixinBot.session_id = CONFIG['session_id']
MixinBot.pin_token = CONFIG['pin_token']
MixinBot.private_key = CONFIG['private_key']

describe "config" do
  it 'should config right' do
    MixinBot.api.client_id.wont_be_nil
    MixinBot.api.client_secret.wont_be_nil
    MixinBot.api.session_id.wont_be_nil
    MixinBot.api.pin_token.wont_be_nil
    MixinBot.api.private_key.wont_be_nil
  end
end
