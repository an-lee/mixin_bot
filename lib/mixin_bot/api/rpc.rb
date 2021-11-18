# frozen_string_literal: true

module MixinBot
  class API
    module Rpc
      def rpc_proxy(method, params = [], access_token: nil)
        path = '/external/proxy'
        payload = {
          method: method,
          params: params
        }

        access_token ||= access_token('POST', path, payload.to_json)
        authorization = format('Bearer %<access_token>s', access_token: access_token)
        client.post(path, headers: { 'Authorization': authorization }, json: payload)
      end

      # send a signed transaction to main net
      def send_raw_transaction(raw, access_token: nil)
        rpc_proxy('sendrawtransaction', [raw], access_token: access_token)
      end

      def get_transaction(hash, access_token: nil)
        rpc_proxy('gettransaction', [hash], access_token: nil)
      end

      def get_utxo(hash, index = 0, access_token: nil)
        rpc_proxy 'getutxo', [hash, index], access_token: access_token
      end

      def get_snapshot(hash, access_token: nil)
        rpc_proxy 'getsnapshot', [hash], access_token: access_token
      end

      def list_snapshots(offset = 0, count = 10, sig = false, tx = false, access_token: nil)
        rpc_proxy 'listsnapshots', [offset, count, sig, tx], access_token: access_token
      end

      def list_mint_works(offset = 0, access_token: nil)
        rpc_proxy 'listmintworks', [offset], access_token: access_token
      end

      def list_mint_distributions(offset = 0, count = 10, tx = false, access_token: nil)
        rpc_proxy 'listmintdistributions', [offset, count, tx], access_token: access_token
      end
    end
  end
end
