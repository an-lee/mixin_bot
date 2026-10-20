# Summary: lib/mixin_bot/outputs/envelope.rb
`size: 5097`
`Outputs::Envelope`: application-facing view of one output — `output_id`, `amount` (BigDecimal), `asset_id`, `state`, `spent?`, `sequence`, `transaction_hash`, `output_index`. `memo`, `opponent_id`, `trace_id` bridge lazily via `create_safe_snapshot_notification`, at most once per receipt (flag written even on failure); resolved values are cached back onto the receipt.
