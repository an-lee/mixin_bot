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
        public_key:
      }

      client.post path, **payload
    end
  end
end
