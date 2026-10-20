# Summary: lib/mixin_bot/utils/amount.rb
`size: 2661`
`Utils::Amount`: decimal-safe unit conversion mirroring the Node SDK. `format_units(amount, decimals)` divides by 10**decimals and returns an exact decimal string; `parse_units(amount, decimals)` multiplies and floors to integer minor units. Both raise `ArgumentError` for malformed amounts or negative decimals.
