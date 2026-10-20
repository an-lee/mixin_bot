# Summary: lib/mixin_bot/rails.rb
`size: 1047`
Opt-in Rails entry point. `require 'mixin_bot/rails'` loads `mixin_bot`, requires the `rails` gem (raises a descriptive LoadError otherwise), then loads `blaze/router`, `outputs`, `transfers`, `rails/railtie` and `notifications/mixin_channel`. Plain `require 'mixin_bot'` never touches Rails.
