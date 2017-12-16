module ModelHelper
  #ログ出力
  def log(title = "-", val = nil)
    print "\n\n\n"
    logger.ap "#{title}----------------------------", :info
    logger.ap val, :info if val.present?
    print "\n\n\n"
  end

end
