require 'mixin_bot'
require 'base64'
require 'yaml'

CONFIG = YAML.load_file("#{File.dirname __FILE__}/config.yml")
MixinBot.client_id = CONFIG['client_id']
MixinBot.client_secret = CONFIG['client_secret']
MixinBot.session_id = CONFIG['session_id']
MixinBot.pin_token = CONFIG['pin_token']
MixinBot.private_key = CONFIG['private_key']

EM.run {
  MixinBot.api.start_blaze_connnect
}