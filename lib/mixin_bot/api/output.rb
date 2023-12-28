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

        path = format(
          '/safe/outputs?asset=%<asset>s&limit=%<limit>s&offset=%<offset>s&state=%<state>s&members=%<members_hash>s&threshold=%<threshold>s&order=%<order>s',
          asset:,
          limit:,
          offset:,
          state:,
          members_hash:,
          threshold:,
          order:
        )
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token:)
        client.get(path, headers: { Authorization: authorization })
      end

      def safe_output(id)
        path = format('/safe/outputs/%<id>s', id:)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token:)
        client.get(path, headers: { Authorization: authorization })
      end
    end
  end
end
