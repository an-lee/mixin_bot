# Summary: lib/mixin_bot/registry.rb
`size: 2694`
`MixinBot::Registry` (extended into `MixinBot`): named multi-bot registry. `register_bot(name, **kwargs)` builds a `MixinBot::API` and freezes its config (raises `MixinBot::ArgumentError` on empty kwargs or duplicate name); `bot(name)` (KeyError when missing); `bot_by_app_id(app_id)` (default API when it matches the global config, else the registered bot, else nil); `bots` hash of name => API.
