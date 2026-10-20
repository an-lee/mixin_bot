# Summary: lib/mixin_bot/outputs/poller.rb
`size: 6897`
`Outputs::Poller`: polling loop. `#run`/`#poll_once`/`#stop`. Cycle = sweep undispatched receipts, fetch a page of `safe_outputs` (ASC), record each output in the receipt store (the dedup gate), enqueue matching processors, then advance the cursor. Resume cursor is derived from receipts (`cursor_value` = max output `sequence` per bot). Collaborators (receipts, processors, enqueuer, sleeper, clock, logger) are injectable.
