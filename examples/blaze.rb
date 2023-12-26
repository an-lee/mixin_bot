# frozen_string_literal: true

require './lib/mixin_bot'
require 'base64'
require 'yaml'

CONFIG = YAML.load_file("#{File.dirname __FILE__}/config.yml")
MixinBot.configure do
  app_id = CONFIG['app_id']
  client_secret = CONFIG['client_secret']
  session_id = CONFIG['session_id']
  server_public_key = CONFIG['server_public_key']
  session_private_key = CONFIG['session_private_key']
end

# default connect
# EM.run {
#   MixinBot.api.start_blaze_connect
# }

EM.run do
  MixinBot.api.start_blaze_connect do
    def on_open(blaze, _event)
      p [Time.now.to_s, :on_open]
      blaze.send list_pending_message
    end

    def on_message(blaze, event)
      raw = JSON.parse read_ws_message(event.data)
      p [Time.now.to_s, :on_message, raw&.[]('action')]

      blaze.send acknowledge_message_receipt(raw['data']['message_id']) unless raw&.[]('data')&.[]('message_id').nil?
    end

    # def on_error(blaze, event)
    #   p [Time.now.to_s, :on_error]
    # end

    # def on_close(blaze, event)
    #   p [Time.now.to_s, :on_close, event.code, event.reason]
    # end
  end
end
