# Summary: lib/mixin_bot/transfers/reconcile.rb
`size: 1646`
`Transfers::Reconcile`: resolves an indeterminate transfer outcome. Looks up `safe_snapshot_by_trace`; a snapshot means the transfer landed (confirmed), no snapshot means nothing landed and the transfer is re-sent with the same trace id. Returns `:confirmed`, `:resent` or `:failed`.
