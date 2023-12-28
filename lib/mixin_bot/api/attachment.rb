# frozen_string_literal: true

module MixinBot
  class API
    module Attachment
      # Sample Response
      # {
      #   "data":{
      #     "type":"attachment",
      #     "attachment_id":"7a54e394-1626-4cd4-b967-543932c2a032",
      #     "upload_url":"https://moments-shou-tv.s3.amazonaws.com/mixin/attachments/xxx",
      #     "view_url":"https://moments.shou.tv/mixin/attachments/1526305123xxxx"
      #   }
      # }
      # Once get the upload_url, use it to upload the your file via PUT request
      def create_attachment(access_token: nil)
        path = '/attachments'
        client.post path, access_token:
      end

      def upload_attachment(file)
        attachment = create_attachment['data']

        url = attachment.delete('upload_url')
        conn = Faraday.new(url:) do |f|
          f.adapter :net_http

          f.request :multipart
          f.request :retry
          f.response :raise_error
          f.response :logger if config.debug
        end

        conn.put(url) do |req|
          req.headers = {
            'x-amz-acl': 'public-read',
            'Content-Type': 'application/octet-stream'
          }
          req.body = Faraday::UploadIO.new(file, 'octet/stream')

          if file.respond_to?(:length)
            req.headers['Content-Length'] = file.length.to_s
          elsif file.respond_to?(:stat)
            req.headers['Content-Length'] = file.stat.size.to_s
          end
        end

        attachment
      end

      def attachment(attachment_id, access_token: nil)
        path = format('/attachments/%<id>s', id: attachment_id)
        client.get path, access_token:
      end
    end
  end
end
