# frozen_string_literal: true

module MVM
  class Client
    SERVER_SCHEME = 'https'

    attr_reader :host

    def initialize(host)
      @host = host
      @conn = Faraday.new(url: "#{SERVER_SCHEME}://#{host}") do |f|
        f.request :json
        f.request :retry
        f.response :raise_error
        f.response :logger
        f.response :json
      end
    end

    def get(path, **)
      @conn.get(path, **).body
    end

    def post(path, **)
      @conn.post(path, **).body
    end
  end
end
