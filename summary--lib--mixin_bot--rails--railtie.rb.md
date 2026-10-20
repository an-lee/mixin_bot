# Summary: lib/mixin_bot/rails/railtie.rb
`size: 1868`
`MixinBot::Railtie < ::Rails::Railtie` (deliberately not `MixinBot::Rails`, which would shadow `::Rails`). Excludes `app/mixin` from default autoload paths, then re-pushes it with `app.autoloaders.main.push_dir(mixin_root, namespace: Mixin)`. Loads `tasks/poller.rake`. Generator discovery is automatic.
