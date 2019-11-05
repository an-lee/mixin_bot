# frozen_string_literal: true

module MixinBot
  class Client
    SERVER_SCHEME = 'https'

    attr_reader :host

    def initialize(host = 'api.mixin.one')
      @host = host
    end

    def get(path, options = {})
      request(:get, path, options)
    end

    def post(path, options = {})
      request(:post, path, options)
    end

    private

    def request(verb, path, options = {})
      uri = uri_for path

      options[:headers] ||= {}
      options[:headers]['Content-Type'] ||= 'application/json'

      begin
        response = HTTP.timeout(connect: 5, write: 5, read: 5).request(verb, uri, options)
      rescue HTTP::Error => e
        raise Errors::HttpError, e.message
      end

      raise Errors::APIError.new(nil, response.to_s) unless response.status.success?

      parse_response(response) do |parse_as, result|
        case parse_as
        when :json
          break result if result[:errcode].nil? || result[:errcode].zero?

          raise Errors::APIError.new(result[:errcode], result[:errmsg])
        else
          result
        end
      end
    end

    def uri_for(path)
      uri_options = {
        scheme: SERVER_SCHEME,
        host: host,
        path: path
      }
      Addressable::URI.new(uri_options)
    end

    def parse_response(response)
      content_type = response.headers[:content_type]
      parse_as = {
        %r{^application\/json} => :json,
        %r{^image\/.*} => :file,
        %r{^text\/html} => :xml,
        %r{^text\/plain} => :plain
      }.each_with_object([]) { |match, memo| memo << match[1] if content_type =~ match[0] }.first || :plain

      if parse_as == :plain
        result = JSON.parse(response&.body&.to_s)
        result && yield(:json, result)

        yield(:plain, response.body)
      end

      case parse_as
      when :json
        result = JSON.parse(response.body.to_s)
      when :file
        extension =
          if response.headers[:content_type] =~ %r{^image\/.*}
            case response.headers['content-type']
            when 'image/gif'  then '.gif'
            when 'image/jpeg' then '.jpg'
            when 'image/png'  then '.png'
            end
          else
            ''
          end

        begin
          file = Tempfile.new(['mixin-file-', extension])
          file.binmode
          file.write(response.body)
        ensure
          file&.close
        end

        result = file
      when :xml
        result = Hash.from_xml(response.body.to_s)
      else
        result = response.body
      end

      yield(parse_as, result)
    end
  end
end
