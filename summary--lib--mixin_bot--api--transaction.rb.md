# Summary: lib/mixin_bot/api/transaction.rb
`size: 13970`
`API::Transaction`: Safe transaction building and signing. `build_safe_transaction(utxos:, receivers:, extra:)` validates inputs, computes change, derives ghost keys and returns the version-5 envelope; `verify_raw_transaction`, `create_safe_transaction_request`, `send_safe_transaction`, `safe_transaction`, `sign_safe_transaction`, `create_safe_keys`, `generate_safe_keys`, plus object/inscribe/occupy transaction builders and storage-cost helpers.
