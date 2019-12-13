# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require './lib/mixin_bot'
require 'yaml'

CONFIG = YAML.load_file("#{File.dirname __FILE__}/config.yml")
PIN_CODE = CONFIG['pin_code'].to_s
TEST_UID = '7ed9292d-7c95-4333-aa48-a8c640064186'
TEST_UID_2 = 'a67c6e87-1c9e-4a1c-b81c-47a9f4f1bff1'
TEST_MIXIN_ID = '37230199'
CNB_ASSET_ID = '965e5c6e-434c-3fa9-b780-c50f43cd955c'
CNB_MIXIN_ID = 'b9f49cf777dc4d03bc54cd1367eebca319f8603ea1ce18910d09e2c540c630d8'
ETH_ASSET_ID = '43d61dcd-e413-450d-80b8-101d5e903357'
EOS_ASSET_ID = '6cfe566e-4aad-470b-8c9a-2fd35b49c68d'
WITHDRAW_ETH_ADDRESS = '0xa6c20096dee08a32398029b5eb410345f7fbbcca'
WITHDRAW_EOS_ACCOUNT_NAME = 'pxneosincome'
WITHDRAW_EOS_ACCOUNT_TAG = 'YET7JMC7'
MULTI_SIGN_CODE_ID = '4e4c7f9e-ef12-46d4-a552-4c173f2bb1ca'
MULTI_SIGN_MEMBERS = %w[0508a116-1239-4e28-b150-85a8e3e6b400 7ed9292d-7c95-4333-aa48-a8c640064186 a67c6e87-1c9e-4a1c-b81c-47a9f4f1bff1].freeze

MixinBot.client_id = CONFIG['client_id']
MixinBot.client_secret = CONFIG['client_secret']
MixinBot.session_id = CONFIG['session_id']
MixinBot.pin_token = CONFIG['pin_token']
MixinBot.private_key = CONFIG['private_key']
MixinBot.api_host = 'mixin-api.zeromesh.net'
MixinBot.blaze_host = 'mixin-blaze.zeromesh.net'
