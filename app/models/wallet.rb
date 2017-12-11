class Wallet < ApplicationRecord

  #対象データ分、お財布にデータを追加する
  #c_type:通貨
  #money: 金額or数量
  def self.add_wallet(c_type,money)
    wallet = self.where(currency_type: c_type).first

    #お財布に該当通貨なし：Insert
    if wallet == nil
      self.create({money: money, currency_type: c_type, is_loscat: false})
    else
      #お財布に該当通貨あり:Update
      #該当金額分を加算
      wallet.money += money
      wallet.save
    end

    #入出金履歴
    if c_type == "jpy"
      WalletHistory.create({currency_type: :jpy,money: wallet.money})
    end

  end
end