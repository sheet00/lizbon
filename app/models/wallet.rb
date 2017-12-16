class Wallet < ApplicationRecord

  #対象データ分、お財布にデータを追加する
  #c_type:通貨
  #money: 金額or数量
  #trade_time: 入出金履歴用トレード確定時間
  def self.add_wallet(c_type,money,trade_time)
    wallet = self.where(currency_type: c_type).first

    #お財布に該当通貨なし：Insert
    if wallet == nil
      wallet = self.create(money: money, currency_type: c_type, is_loscat: false)
    else
      #お財布に該当通貨あり:Update
      #該当金額分を加算
      wallet.money += money
      wallet.save
    end

    #入出金履歴
    if c_type == "jpy"
      WalletHistory.create(currency_type: :jpy,money: wallet.money, trade_time: trade_time)
    end


    ApplicationController.helpers.log("[add_wallet]",wallet)
  end

  # お財布-未成約分の金額
  # オーダー分は「なくなった」ことにしておく
  # 買い：買い注文を出したので、「JPY」から約定金額をマイナス
  # 売り：売りにだしているので、「対象通貨」から対象通貨をマイナス
  # キャンセルした段階で未成約が計算対象外になり、お財布-未成約0で結果お財布のみになる
  def self.exclude_order
    wallets = self.all
    w_jpy = wallets.select{|w| w.currency_type == "jpy"}.first

    wallets.each{|w|
      ActiveOrder.where(currency_pair: "#{w.currency_type}_jpy").each{|o|
        if o.action == "bid"
          w_jpy.money += -1 * o.contract_price
        else
          w.money += -1 * o.amount
        end
      }
    }

    return wallets
  end
end
