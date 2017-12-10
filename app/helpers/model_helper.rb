module ModelHelper

  #ログ出力
  def log(title = "-",val)
    print "\n\n\n"
    pp "#{title}----------------------------"
    pp val
    print "\n\n\n"
  end


end
