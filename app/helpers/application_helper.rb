module ApplicationHelper
  #トレード文字列変換
  def t(val)
    case val
    when "bid" then
      "買い"
    when "ask" then
      "売り"
    when "wait" then
      "成約待ち"
    else
      val
    end
  end

  def label_state(trade_type)
    case trade_type
    when "bid","ask"
      "info"
    when "キャンセル：ロスカット"
      "danger"
    when "買い確定","売り確定"
      "success"
    else
      "default"
    end
  end

  def page_title
    title = "lizbon"
    title = @page_title + " | " + title if @page_title
    title
  end


  #時価総額算出
  def get_market_capital
    capital = 0

    #お財布
    Wallet.all.each {|w|
      if w.currency_type == "jpy"
        capital += w.money
      else
        amount = w.money
        price = get_recent_price("#{w.currency_type}_jpy")
        capital += amount * price
      end
    }

    return capital
  end

  private

  #対象通貨の最新価格を求める
  def get_recent_price(c_pair)
    ch = CurrencyHistory.where(currency_pair: c_pair).order("timestamp desc").first
    return ch.present? ? ch.price : 0
  end


end
