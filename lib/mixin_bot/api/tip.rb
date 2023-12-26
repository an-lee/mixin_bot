# frozen_string_literal: true

module MixinBot
  class API
    module Tip
      TIP_ACTIONS = %w[
        TIP:VERIFY:
        TIP:ADDRESS:ADD:
        TIP:ADDRESS:REMOVE:
        TIP:USER:DEACTIVATE:
        TIP:EMERGENCY:CONTACT:CREATE:
        TIP:EMERGENCY:CONTACT:READ:
        TIP:EMERGENCY:CONTACT:REMOVE:
        TIP:PHONE:NUMBER:UPDATE:
        TIP:MULTISIG:REQUEST:SIGN:
        TIP:MULTISIG:REQUEST:UNLOCK:
        TIP:COLLECTIBLE:REQUEST:SIGN:
        TIP:COLLECTIBLE:REQUEST:UNLOCK:
        TIP:TRANSFER:CREATE:
        TIP:WITHDRAWAL:CREATE:
        TIP:TRANSACTION:CREATE:
        TIP:OAUTH:APPROVE:
        TIP:PROVISIONING:UPDATE:
        TIP:APP:OWNERSHIP:TRANSFER:
        SEQUENCER:REGISTER:
      ].freeze

      def encrypt_tip_pin(pin, action, *params)
        raise ArgumentError, 'invalid action' unless TIP_ACTIONS.include? action

        _private_key = MixinBot::Utils.decode_key pin
        msg = action + params.map(&:to_s).join

        if action != 'TIP:VERIFY:'
          msg = Digest::SHA256.digest msg
        end

        signature = JOSE::JWA::Ed25519.sign msg, _private_key

        encrypt_pin signature.unpack1('H*')
      end
    end
  end
end
