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
        raise HttpError, e.message
      end

      raise RequestError, response.to_s unless response.status.success?

      parse_response(response) do |parse_as, result|
        case parse_as
        when :json
          if result['error'].nil?
            result.merge! result['data'] if result['data'].is_a? Hash
            break result
          end

          errmsg = "errcode: #{result['error']['code']}, errmsg: #{result['error']['description']}"

          # status code description
          # 202	400	The request body can’t be pasred as valid data.
          # 202	401	Unauthorized.
          # 202	403	Forbidden.
          # 202	404	The endpoint is not found.
          # 202	429	Too Many Requests.
          # 202	10006	App update required.
          # 202	20116	The group chat is full.
          # 500	500	Internal Server Error.
          # 500	7000	Blaze server error.
          # 500	7001	The blaze operation timeout.
          case result['error']['code']
          when 401
            raise UnauthorizedError, errmsg
          when 403, 20116
            raise ForbiddenError, errmsg
          when 400, 404, 429, 10006, 20133, 500, 7000, 7001
            raise ResponseError, errmsg
          else
            raise ResponseError, errmsg
          end
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
        %r{^application/json} => :json,
        %r{^image/.*} => :file,
        %r{^text/html} => :xml,
        %r{^text/plain} => :plain
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
          if response.headers[:content_type] =~ %r{^image/.*}
            {
              'image/gif': '.gif',
              'image/jpeg': '.jpg',
              'image/png': '.png'
            }[response.headers['content-type']]
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
