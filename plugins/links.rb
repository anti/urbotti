class Links
  include Cinch::Plugin

  attr_accessor :redis

  match "!links",        :method => :links
  match /https?:\/\//,   :use_prefix => false, :method => :link

  def initialize(*args)
    super
    @redis = Redis.new
  end

  def links(m)
    m.reply "Links count: #{@redis.dbsize}"
  end

  def link(m)
    url = URI.extract(m.message, ["http", "https"]).first
    link = {
      line: m.message,
      url: url,
      nick: m.user.nick,
      pasted_at: Time.now.strftime("%d-%m-%Y %H:%M:%S")
    }

    title = parse(url)

    if @redis.get(url)
      old_link = JSON.parse(@redis.get(url))
      if old_link['nick'] != m.user.nick # Don't nag the users own links
        m.reply "WANHA!"
        m.reply "#{old_link['pasted_at']} <#{old_link['nick']}> #{old_link['line']}"
      end
    else
      @redis.set(url, link.to_json)
      m.reply "[#{title}]" unless title.nil?
    end
  end

  private

    def parse uri
      call = Curl::Easy.perform(uri) do |easy|
        easy.follow_location = true
        easy.max_redirects = 3
      end

      html = Nokogiri::HTML(call.body_str)
      title = html.at_xpath('//title')
      CGI.unescape_html title.text.gsub(/\s+/, ' ')
    rescue
      puts "#{$!}"
    end

    def youtube_link?(url)
      url[/youtu/]
    end

    def youtube_hash(string)
      hash = string.match(/watch\?v=(\w+)/) || string.match(/youtu.be\/(\w+)/)
      hash[1] unless hash.nil?
    end

end
