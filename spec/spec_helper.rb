# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require './lib/mixin_bot'
require 'yaml'

CONFIG = YAML.load_file("#{File.dirname __FILE__}/config.yml")
PIN_CODE = CONFIG['pin'].to_s
TEST_UID = '7ed9292d-7c95-4333-aa48-a8c640064186'
TEST_UID_2 = 'a67c6e87-1c9e-4a1c-b81c-47a9f4f1bff1'
TEST_MIXIN_ID = '37230199'
XIN_ASSET_ID = 'c94ac88f-4671-3976-b60a-09064f1811e8'
CNB_ASSET_ID = '965e5c6e-434c-3fa9-b780-c50f43cd955c'
CNB_MIXIN_ID = 'b9f49cf777dc4d03bc54cd1367eebca319f8603ea1ce18910d09e2c540c630d8'
ETH_ASSET_ID = '43d61dcd-e413-450d-80b8-101d5e903357'
EOS_ASSET_ID = '6cfe566e-4aad-470b-8c9a-2fd35b49c68d'
WITHDRAW_ETH_ADDRESS = '0xa6c20096dee08a32398029b5eb410345f7fbbcca'
WITHDRAW_EOS_ACCOUNT_NAME = 'pxneosincome'
WITHDRAW_EOS_ACCOUNT_TAG = 'YET7JMC7'
MULTI_SIGN_CODE_ID = '4e4c7f9e-ef12-46d4-a552-4c173f2bb1ca'
MULTI_SIGN_MEMBERS = %w[0508a116-1239-4e28-b150-85a8e3e6b400 7ed9292d-7c95-4333-aa48-a8c640064186 a67c6e87-1c9e-4a1c-b81c-47a9f4f1bff1].freeze
MULTI_SIGN_THRESHOLD = 2

NFO_MTG = %w[4b188942-9fb0-4b99-b4be-e741a06d1ebf dd655520-c919-4349-822f-af92fabdbdf4 047061e6-496d-4c35-b06b-b0424a8a400d acf65344-c778-41ee-bacb-eb546bacfb9f a51006d0-146b-4b32-a2ce-7defbf0d7735 cf4abd9c-2cfa-4b5a-b1bd-e2b61a83fabd 50115496-7247-4e2c-857b-ec8680756bee].freeze
NFO_THRESHOLD = 5

MixinBot.configure do
  app_id = CONFIG['app_id']
  client_secret = CONFIG['client_secret']
  session_id = CONFIG['session_id']
  server_public_key = CONFIG['server_public_key']
  session_private_key = CONFIG['session_private_key']
end
