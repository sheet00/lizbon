# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

CurrencyPair.create(
  [
    {currency_pair: "btc_jpy", unit_min: 0.0001, unit_step: 0.0001, unit_digest: 4, currency_digest: -1},
    {currency_pair: "bch_jpy", unit_min: 0.0001, unit_step: 0.0001, unit_digest: 4, currency_digest: -1},
    {currency_pair: "xem_jpy", unit_min: 0.1, unit_step: 0.1, unit_digest: 1, currency_digest: 4},
    {currency_pair: "mona_jpy", unit_min: 1, unit_step: 1, unit_digest: 0, currency_digest: 0},
    {currency_pair: "eth_jpy", unit_min: 0.0001, unit_step: 0.0001, unit_digest: 4, currency_digest: -1},
  ]
)

Wallet.create({currency_type: "jpy", money: 1000, is_losscut: false})

Target.create([{currency_type: "btc"},{currency_type: "bch"},{currency_type: "xem"},{currency_type: "eth"}])

TradeSetting.create(
  [
    {trade_type: :buy, percent: 0.99},
    {trade_type: :sell_upper, percent: 1.05},
    {trade_type: :sell_lower, percent: 0.9}
  ]
)
