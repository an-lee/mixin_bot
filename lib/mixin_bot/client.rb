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

          errmsg = "#{verb.upcase}|#{path}, errcode: #{result['error']['code']}, errmsg: #{result['error']['description']}, request_id: #{response&.[]('X-Request-Id')}, server_time: #{response&.[]('X-Server-Time')}'"

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
          # 202	10002	Illegal request paramters.
          # 202	20117	Insufficient balance。
          # 202	20118	PIN format error.
          # 202	20119	PIN error.
          # 202	20120	Transfer amount is too small.
          # 202	20121	Authorization code has expired.
          # 202	20124	Insufficient withdrawal fee.
          # 202	20125	The transfer has been paid by someone else.
          # 202	20127	The withdrawal amount is too small.
          # 202	20131	Withdrawal Memo format error.
          # 500	30100	The current asset's public chain synchronization error.
          # 500	30101	Wrong private key.
          # 500	30102	Wrong withdrawal address.
          # 500	30103	Insufficient pool.
          # 500	7000	WebSocket server error.
          # 500	7001	WebSocket operation timeout.
          case result['error']['code']
          when 401, 20121
            raise UnauthorizedError, errmsg
          when 403, 20116, 10002, 429
            raise ForbiddenError, errmsg
          when 404
            raise NotFoundError, errmsg
          when 400, 10006, 20133, 500, 7000, 7001
            raise ResponseError, errmsg
          when 20117
            raise InsufficientBalanceError, errmsg
          when 20118, 20119
            raise PinError, errmsg
          when 30103
            raise InsufficientPoolError, errmsg
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
