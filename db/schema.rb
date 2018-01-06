# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171228085624) do

  create_table "active_orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "order_id", null: false
    t.string "currency_pair", null: false
    t.string "action", null: false
    t.decimal "amount", precision: 12, scale: 4, null: false
    t.decimal "price", precision: 12, scale: 4, null: false
    t.string "timestamp", null: false
    t.string "transaction_id", null: false
    t.decimal "limit", precision: 12, scale: 4
    t.decimal "contract_price", precision: 12, scale: 4, null: false
    t.decimal "lower_limit", precision: 12, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bots", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "currency_type", null: false
    t.string "trade_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "capitals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "trade_time", null: false
    t.string "currency_pair", null: false
    t.decimal "capital", precision: 12, scale: 4, null: false
    t.integer "bid_trade_id", null: false
    t.integer "ask_trade_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ask_trade_id"], name: "index_capitals_on_ask_trade_id"
    t.index ["bid_trade_id"], name: "index_capitals_on_bid_trade_id"
  end

  create_table "currency_averages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "currency_pair", null: false
    t.decimal "price", precision: 14, scale: 4, null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_pair"], name: "index_currency_averages_on_currency_pair"
  end

  create_table "currency_histories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "currency_pair", null: false
    t.string "trade_type", null: false
    t.decimal "price", precision: 14, scale: 4, null: false
    t.decimal "amount", precision: 14, scale: 4, null: false
    t.string "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_pair", "timestamp"], name: "index_currency_histories_on_currency_pair_and_timestamp"
  end

  create_table "currency_pairs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "currency_pair", null: false
    t.decimal "unit_min", precision: 12, scale: 4, null: false
    t.decimal "unit_step", precision: 12, scale: 4, null: false
    t.integer "unit_digest", null: false
    t.integer "currency_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "targets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "currency_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trade_histories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "order_id", null: false
    t.string "currency_pair", null: false
    t.string "action", null: false
    t.decimal "amount", precision: 12, scale: 4, null: false
    t.decimal "price", precision: 12, scale: 4, null: false
    t.decimal "fee", precision: 12, scale: 4, null: false
    t.decimal "fee_amount", precision: 12, scale: 4, null: false
    t.decimal "contract_price", precision: 12, scale: 4, null: false
    t.string "your_action", null: false
    t.string "timestamp", null: false
    t.string "transaction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trade_settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "trade_type", null: false
    t.decimal "value", precision: 10, scale: 4, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wallet_histories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "currency_type", null: false
    t.decimal "money", precision: 12, scale: 4, null: false
    t.datetime "trade_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wallets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "currency_type", null: false
    t.decimal "money", precision: 14, scale: 4, null: false
    t.boolean "is_losscut", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
