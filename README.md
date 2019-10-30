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

### Initialize params

To use MixinBot api, you should set the keys first.

```ruby
MixinBot.client_id = '25696f85-b7b4-4509-8c3f-2684a8fc4a2a'
MixinBot.client_secret = 'd9dc58107bacde671...'
MixinBot.session_id ='25696f85-b7b4-4509-8c3f-2684a8fc4a2a'
MixinBot.pin_token = 'b0pjBUKI0Vp9K+NspaL....'
MixinBot.private_key = <<~PRIVATE_KEY
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQDQYjiR/Te6Bh/1bk8gWRbQkrX0AIGPja1DLUQHu5Uw9M4P53O3
f4pDCGoN3R5+LYjODtquOwmEjcMhbhp6XarrnJVXH8WGmJcpjVwGtwIjPTeRMu4Z
...
-----END RSA PRIVATE KEY-----
PRIVATE_KEY

# pin_code is not necessary unless you need to transfer assets
MixinBot.pin_code = '431005'
```

### Call mixin apis

Then you can use MixinBot by call `MixinBot.api`, for example

```ruby
# get the bot profile
MixinBot.api.read_me

# get assets of the bot
MixinBot.api.read_assets

# transfer asset to somebody
MixinBot.api
  .create_transfer(
    '123456', # pin_code
    asset_id: '965e5c6e-434c-3fa9-b780-c50f43cd955c', # the asset uuid to transfer
    opponent_id: '6ae1c7ae-1df1-498e-8f21-d48cb6d129b5', # receiver's mixin uuid
    amount: 0.00000001, # amount
    memo: 'test from MixinBot', # memo, 140 length at max
    trace_id: '0798327a-d499-416e-9b26-5cdc5b7d841e' # a uuid to trace transfer
)

# etc
```

### Connect Mixin Blaze

Your bot can receive/send messages from/to any users in Mixin Network, including all users in Mixin Messenger by connecting to Mixin Blaze.

With MixinBot, doing this is super easy.

```ruby
# run it in a EventMachine
EM.run {
  MixinBot.api.start_blaze_connnect do
    # do something when the websocket connected
    def on_open(blaze, _event)
      p [Time.now.to_s, :on_open]

      # send the list_pending_message to receive messages
      blaze.send list_pending_message
    end

    # do something when receive message
    def on_message(blaze, event)
      raw = JSON.parse read_ws_message(event.data)
      p [Time.now.to_s, :on_message, raw&.[]('action')]

      blaze.send acknowledge_message_receipt(raw['data']['message_id']) unless raw&.[]('data')&.[]('message_id').nil?
    end

    # do something when websocket error
    def on_error(blaze, event)
      p [Time.now.to_s, :on_error]
    end

    # do something when websocket close
    def on_close(blaze, event)
      p [Time.now.to_s, :on_close, event.code, event.reason]
    end
  end
}
```

### Multiple Bot management

If you need to manage multiple mixin bot, you can config like this.

```ruby
bot1_api = MixinBot::API.new(
  client_id: '...',
  client_secret: '...',
  session_id: '...',
  pin_token: '...',
  private_key: '...',
  pin_code: '123456'
)

bot2_api = MixinBot::API.new(
  client_id: '...',
  client_secret: '...',
  session_id: '...',
  pin_token: '...',
  private_key: '...',
  pin_code: '123456'
)

bot1_api.read_me
bot2_api.read_me
```

## More Example

See in the `Spec` files.

For WebSocket use case, see in `examples/blaze.rb`.

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
