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

    def get(path, **options)
      @conn.get(path, **options).body
    end

    def post(path, **options)
      @conn.post(path, **options).body
    end
  end
end
