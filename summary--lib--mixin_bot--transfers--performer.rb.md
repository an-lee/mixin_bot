# Summary: lib/mixin_bot/transfers/performer.rb
`size: 2472`
`Transfers::Performer`: runs the Safe pipeline for one transfer via `create_safe_transfer` with the record's `trace_id` as request id. Outcome mapping: success -> broadcast then confirmed; `MixinBot::APIError` -> failed (never retried); network errors (`Faraday::Error`, `SocketError`, `Errno::ETIMEDOUT`, `Timeout::Error`) -> reconciling.
