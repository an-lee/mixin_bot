module MixinBot
  class API
    module Message
      def read_message(data)
        io = StringIO.new(data.pack('c*'), 'rb')
        gzip = Zlib::GzipReader.new io
        msg = gzip.read
        gzip.close
        return msg
      end

      def write_message(action, params)
        msg = {
          "id": SecureRandom.uuid,
          "action":  action,
          "params": params
        }.to_json

        io = StringIO.new 'wb'
        gzip = Zlib::GzipWriter.new io
        gzip.write msg
        gzip.close
        data = io.string.unpack('c*')
      end
    end
  end
end
