
module MixinBot
  class API
    module Tip
      TIP_ACTIONS = %w[
        TIP:TRANSFER:CREATE:
      ].freeze

      def encrypt_tip_pin(pin, action, *params)
        raise ArgumentError, 'invalid action' unless TIP_ACTIONS.include? action
        raise ArgumentError, 'invalid pin' if pin.length != 128

        private_key = [pin].pack('H*')
        hex = Digest::SHA256.hexdigest(action + params.join)
        signature = JOSE::JWA::Ed25519.sign hex, private_key

        encrypt_pin signature.unpack1('H*')
      end
    end
  end
end
