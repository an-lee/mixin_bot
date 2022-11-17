# frozen_string_literal: true

module MVM
  class Bridge
    attr_reader :client

    def initialize
      @client = MVM::Client.new 'bridge.mvm.dev'
    end

    def info
      client.get '/'
    end

    def user(public_key)
      path = '/users'

      payload = {
        public_key: public_key
      }

      client.post path, json: payload
    end

    def extra(receivers: [], threshold: 1, extra: '')
      return if receivers.blank?

      path = '/extra'

      payload = {
        receivers: receivers,
        threshold: threshold,
        extra: extra
      }

      client.post path, json: payload
    end

    def mirror
    end
  end
end
