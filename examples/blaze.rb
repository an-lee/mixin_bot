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
  def start_connect
    ws = MixinBot.blaze

    ws.on :open do |event|
      puts [Time.now, :open]
      ws.send MixinBot.api.list_pending_message
    end

    ws.on :message do |event|
      raw = JSON.parse MixinBot.api.read_ws_message(event.data)
      puts [Time.now, :message, raw&.[]('action')]

      data = raw['data']
      next if data.nil?

      # send receipt
      ws.send MixinBot.api.acknowledge_message_receipt(data['message_id'])

      # send reply
      if data['category'] == 'PLAIN_TEXT'
        reply = MixinBot.api.plain_text(
          conversation_id: data['conversation_id'],
          recipient_id: data['user_id'],
          data: Base64.decode64(data['data'])
        )
        ws.send MixinBot.api.write_ws_message(params: reply)
      end
    end

    ws.on :error do |event|
      p [:error]
    end

    ws.on :close do |event|
      p [Time.now, :close, event.code, event.reason]
      start_connect
    end
  end
  
  start_connect
}