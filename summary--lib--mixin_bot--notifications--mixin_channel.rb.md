# Summary: lib/mixin_bot/notifications/mixin_channel.rb
`size: 2630`
`Notifications::MixinChannel < ::Noticed::Channel`. File returns early unless `Noticed::Channel` is defined. `#deliver` sends `api.send_message(payload)`; the payload comes from the notification's `mixin_message` (PLAIN_TEXT, PLAIN_POST or APP_CARD) and the recipient from `mixin_recipient` or the record's `mixin_user_id`. Supports `deliver_by :mixin, bot: :shop`.
