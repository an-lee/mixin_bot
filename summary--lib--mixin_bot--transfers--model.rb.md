# Summary: lib/mixin_bot/transfers/model.rb
`size: 4147`
`Transfers::Model` ActiveRecord concern for the `MixinTransfer` ledger. STATES: pending, broadcast, confirmed, failed, reconciling. TRANSITIONS graph enforces legal edges. `transition_to!` (audited, raises `MixinBot::ArgumentError`), `perform!`, `reconcile!`, `bot_api`, class method `reconcile_pending!`. `trace_id` is unique.
