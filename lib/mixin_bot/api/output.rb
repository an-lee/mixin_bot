# frozen_string_literal: true

module MixinBot
  class API
    module Output
      def outputs(**kwargs)
        limit = kwargs[:limit] || 100
        offset = kwargs[:offset] || ''
        state = kwargs[:state] || ''
        members = kwargs[:members] || []
        threshold = kwargs[:threshold] || ''
        access_token = kwargs[:access_token]
        members = SHA3::Digest::SHA256.hexdigest(members&.sort&.join)

        path = format(
          '/multisigs/outputs?limit=%<limit>s&offset=%<offset>s&state=%<state>s&members=%<members>s&threshold=%<threshold>s',
          limit: limit,
          offset: offset,
          state: state,
          members: members,
          threshold: threshold
        )
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
      alias multisigs outputs
      alias multisig_outputs outputs

      def create_output(receivers:, index:, hint: nil, access_token: nil)
        path = '/outputs'
        payload = {
          receivers: receivers,
          index: index,
          hint: hint
        }
        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      def build_output(receivers:, index:, amount:, threshold:, hint: nil)
        _output = create_output receivers: receivers, index: index, hint: hint
        {
          amount: format('%.8f', amount.to_d.to_r),
          script: build_threshold_script(threshold),
          mask: _output['mask'],
          keys: _output['keys']
        }
      end

      def build_threshold_script(threshold)
        s = threshold.to_s(16)
        s = s.length == 1 ? "0#{s}" : s
        raise 'NVALID THRESHOLD' if s.length > 2

        "fffe#{s}"
      end

      def safe_outputs(**kwargs)
        asset = kwargs[:asset]
        limit = kwargs[:limit] || 500
        offset = kwargs[:offset] || ''
        state = kwargs[:state] || ''
        access_token = kwargs[:access_token]
        order = kwargs[:order] || 'ASC'
        members = kwargs[:members] || [client_id]
        threshold = kwargs[:threshold] || members.length

        members_hash = SHA3::Digest::SHA256.hexdigest(members&.sort&.join)

        path = format(
          '/safe/outputs?asset=%<asset>s&limit=%<limit>s&offset=%<offset>s&state=%<state>s&members=%<members_hash>s&threshold=%<threshold>s&order=%<order>s',
          asset: asset,
          limit: limit,
          offset: offset,
          state: state,
          members_hash: members_hash,
          threshold: threshold,
          order: order
        )
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end

      def safe_output(id)
        path = format('/safe/outputs/%<id>s', id: id)
        access_token ||= access_token('GET', path, '')
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.get(path, headers: { 'Authorization': authorization })
      end
    end
  end
end
