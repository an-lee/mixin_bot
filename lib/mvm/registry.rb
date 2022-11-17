# frozen_string_literal: true

module MVM
  class Registry
    attr_reader :rpc, :registry

    def initialize(rpc_url: MVM::RPC_URL, registry_address: MVM::REGISTRY_ADDRESS)
      @rpc = Eth::Client.create rpc_url
      @registry = Eth::Contract.from_abi name: 'Registry', address: registry_address, abi: File.open(File.expand_path('./abis/registry.json', __dir__)).read
    end

    def asset(asset_id)
      @rpc.call @registry, 'contracts', asset_id.gsub('-', '').to_i(16)
    end

    def user(user_id)
      multisig [user_id], 1
    end

    def multisig(user_ids, threshold)
      bytes = []
      bytes += MixinBot::Utils.encode_int(user_ids.length)
      bytes += [user_ids.sort.join('').gsub('-', '')].pack('H*').bytes
      bytes += MixinBot::Utils.encode_int(threshold)

      hash = Eth::Util.bin_to_prefixed_hex(Eth::Util.keccak256(bytes.pack('C*')))
      @rpc.call @registry, 'contracts', hash.to_i(16)
    end
  end
end
