# Summary: lib/mixin_bot.rb
`size: 6268`
Top-level MixinBot module. Loads dependencies (faraday, jose, rbnacl, sha3, blake3, faye/websocket, msgpack, active_support), requires all submodules (errors, address, models, api, blaze/reactor, bot_auth, cli, computer, invoice, monitor, registry, url_scheme, utils, nfo, uuid, transaction, version, mvm), and exposes `MixinBot.api`, `MixinBot.config`, `MixinBot.configure`, `MixinBot.utils`, `MixinBot.deprecator` (ActiveSupport::Deprecation, target version `2.0`). Extends `MixinBot::Registry`.
