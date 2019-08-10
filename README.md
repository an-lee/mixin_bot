# MixinBot

An API wrapper for [Mixin Network](https://developers.mixin.one/api)

## Installation

Add to gemfile, and `bundle install`

```ruby
gem 'mixin_bot', ~> '0.1.0'
```

Or

```shell
gem install mixin_bot
```

## Usage

Check it in this toy project:

- [investing_mistakes](https://github.com/an-lee/investing_mistakes)

## Example

- [investing_mistakes](https://github.com/an-lee/investing_mistakes)
- [prsdigg.com](https://prsdigg.com)

## Test

Clone the project:

```shell
git clone https://github.com/an-lee/mixin_bot
```

Update the spec config.yml to your own Mixin App(create in [developers.mixin.one](https://developers.mixin.one/dashboard)).

```shell
cd mixin_bot
mv spec/config.yml.example spec/config.yml
```

Run the test.

```shell
rake
```

## References

- [Mixin Network Document](https://developers.mixin.one/api)
- [mixin_client_demo (python)](https://github.com/myrual/mixin_client_demo)
- [mixin-node (nodejs)](https://github.com/virushuo/mixin-node)

## License

This project rocks and uses MIT-LICENSE.
