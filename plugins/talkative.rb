class Talkative
  include Cinch::Plugin

  match /:\)/, :use_prefix => false, :method => :happy
  match /:\(/, :use_prefix => false, :method => :unhappy
  match /haha/, :use_prefix => false, :method => :happy
  match /heh/, :use_prefix => false, :method => :happy

  def happy(m)
    m.reply ":)" if rand(3) == 0
  end

  def unhappy(m)
    m.reply ":(" if rand(3) == 0
  end
end
