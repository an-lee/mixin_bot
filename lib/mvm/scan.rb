# frozen_string_literal: true

module MVM
  class Scan
    attr_reader :client

    def initialize
      @client = Client.new 'scan.mvm.dev'
    end

    def tokens(address, type: nil)
      path = '/api'
      r = client.get(
        path,
        params: {
          address:,
          action: 'tokenlist',
          module: 'account'
        }
      )['result']

      r = r.filter(&->(token) { token['type'] == type }) if type.present?

      r
    end
  end
end
