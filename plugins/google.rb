class Google
  include Cinch::Plugin

  match /!g\s?(.*)/, :method => :google

  def google(m, search)
    m.reply URI::encode("https://www.google.com/search?q=#{search}")
  end

end
