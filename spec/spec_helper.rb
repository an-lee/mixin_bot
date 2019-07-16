# frozen_string_literal: true

require 'mixin_bot'
require 'yaml'

CONFIG = YAML.load_file("#{File.dirname __FILE__}/config.yml")
PIN_CODE = CONFIG['pin_code'].to_s
TEST_UID = '7ed9292d-7c95-4333-aa48-a8c640064186'
CNB_ASSET_ID = '965e5c6e-434c-3fa9-b780-c50f43cd955c'

MixinBot.client_id = CONFIG['client_id']
MixinBot.client_secret = CONFIG['client_secret']
MixinBot.session_id = CONFIG['session_id']
MixinBot.pin_token = CONFIG['pin_token']
MixinBot.private_key = CONFIG['private_key']
