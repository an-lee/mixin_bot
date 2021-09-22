# frozen_string_literal: true

module MixinBot
  class API
    module Attachment
      # https://developers.mixin.one/api/beta-mixin-message/create-attachment/
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
      def create_attachment
        path = '/attachments'
        access_token ||= access_token('POST', path, {}.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: {})
      end

      def upload_attachment(file)
        attachment = create_attachment['data']

        HTTP
          .timeout(connect: 5, write: 5, read: 5)
          .request(
            :put, 
            attachment.delete('upload_url'), 
            {
              body: file,
              headers: {
                'x-amz-acl': 'public-read',
                'Content-Type': 'application/octet-stream',
              }
          })

        attachment
      end

      def read_attachment(attachment_id)
        path = format('/attachments/%<id>s', id: attachment_id)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
    end
  end
end
