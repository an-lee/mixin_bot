# Summary: lib/mixin_bot/blaze/router.rb
`size: 11035`
`MixinBot::Blaze::Router` — callable that routes decoded Blaze envelopes. `#on(matcher, handler)` DSL: category alias or raw category, or a condition Hash (`category:`, `action:`); first match wins. `CATEGORY_ALIASES` maps text/post/image/data/file/sticker/contact/audio/video/live/location/transfer/snapshot/app_card/app_button_group/buttons/recall. `Router::Message` (decoded view, `#reply`), `Router::Base` (class handlers, `#handle`). Handler errors are logged and re-raised.
