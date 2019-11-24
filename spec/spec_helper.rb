# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require './lib/mixin_bot'
require 'yaml'

CONFIG = YAML.load_file("#{File.dirname __FILE__}/config.yml")
PIN_CODE = CONFIG['pin_code'].to_s
TEST_UID = '7ed9292d-7c95-4333-aa48-a8c640064186'
TEST_MIXIN_ID = '37230199'
CNB_ASSET_ID = '965e5c6e-434c-3fa9-b780-c50f43cd955c'
ETH_ASSET_ID = '43d61dcd-e413-450d-80b8-101d5e903357'
EOS_ASSET_ID = '6cfe566e-4aad-470b-8c9a-2fd35b49c68d'
WITHDRAW_ETH_ADDRESS = '0xa6c20096dee08a32398029b5eb410345f7fbbcca'
WITHDRAW_EOS_ACCOUNT_NAME = 'pxneosincome'
WITHDRAW_EOS_ACCOUNT_TAG = 'YET7JMC7'

MixinBot.client_id = CONFIG['client_id']
MixinBot.client_secret = CONFIG['client_secret']
MixinBot.session_id = CONFIG['session_id']
MixinBot.pin_token = CONFIG['pin_token']
MixinBot.private_key = CONFIG['private_key']
MixinBot.api_host = 'mixin-api.zeromesh.net'
MixinBot.blaze_host = 'mixin-blaze.zeromesh.net'