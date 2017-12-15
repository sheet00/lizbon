module ModelHelper
  #ログ出力
  def log(title = "-",val)
    print "\n\n\n"
    logger.ap "#{title}----------------------------"
    logger.ap val
    print "\n\n\n"
  end

end
