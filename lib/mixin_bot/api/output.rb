# frozen_string_literal: true

module MixinBot
  class API
    module Output
      def build_threshold_script(threshold)
        s = threshold.to_s(16)
        s = "0#{s}" if s.length == 1
        raise 'NVALID THRESHOLD' if s.length > 2

        "fffe#{s}"
      end

      def safe_outputs(**kwargs)
        asset = kwargs[:asset] || kwargs[:asset_id]
        limit = kwargs[:limit] || 500
        offset = kwargs[:offset] || ''
        state = kwargs[:state] || ''
        access_token = kwargs[:access_token]
        order = kwargs[:order] || 'ASC'
        members = kwargs[:members] || [config.app_id]
        threshold = kwargs[:threshold] || members.length

        members_hash = SHA3::Digest::SHA256.hexdigest(members&.sort&.join)

        path = '/safe/outputs'
        params = {
          asset:,
          limit:,
          offset:,
          state:,
          members: members_hash,
          threshold:,
          order:
        }.compact

        client.get path, **params, access_token:
      end

      def safe_output(id, access_token: nil)
        path = format('/safe/outputs/%<id>s', id:)
        client.get path, access_token:
      end
    end
  end
end
