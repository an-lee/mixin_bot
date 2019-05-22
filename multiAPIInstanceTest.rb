require './lib/mixin_bot'
require 'yaml'
require 'csv'

yaml_hash = YAML.load_file('./config.yml')
WALLET_NAME      = "./mybitcoin_wallet.csv"

bot_config = {
                client_id: yaml_hash["MIXIN_CLIENT_ID"],
                session_id: yaml_hash["MIXIN_SESSION_ID"],
                client_secret: yaml_hash["MIXIN_CLIENT_SECRET"],
                pin_token:    yaml_hash["MIXIN_PIN_TOKEN"],
                private_key: yaml_hash["MIXIN_PRIVATE_KEY"]
                }
botAccount = MixinBot.new(bot_config)

table = CSV.read(WALLET_NAME)

wallet_config = {
                client_id: table[0][3],
                session_id: table[0][2],
                client_secret: '',
                pin_token:    table[0][1],
                private_key: table[0][0]
                }
walletAccount = MixinBot.new(wallet_config)

assetsWallet = walletAccount.read_assets()
# p assetsWallet
assetsWallet["data"].each { |x| puts x["symbol"] + " " +
                            x["balance"] + " " + x["public_key"] +
                            x["account_name"] + " " + x["account_tag"]}
p "----------End of Wallet Assets --------------"

assetsBot = botAccount.read_assets()
assetsBot["data"].each { |x| puts x["symbol"] + " " +
                            x["balance"] + " " + x["public_key"] +
                            x["account_name"] + " " + x["account_tag"]}
p "----------End of Bot Assets --------------"
