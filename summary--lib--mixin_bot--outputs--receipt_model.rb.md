# Summary: lib/mixin_bot/outputs/receipt_model.rb
`size: 3374`
`Outputs::ReceiptModel` ActiveRecord concern for the generated `MixinOutput` model. Class methods: `record!` (unique on `(bot_app_id, output_id)`), `mark_enqueued!`, `unenqueued(bot_app_id:, older_than:)`, `cursor_value(bot_app_id:)` (max `sequence`). Including it registers the model as `Outputs.receipt_store` and `Outputs.receipt_loader`.
