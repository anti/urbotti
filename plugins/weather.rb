class Weather
  include Cinch::Plugin

  match /!saa\s?(.*)/, :method => :weather
  match /!sää\s?(.*)/, :method => :weather

  def weather(m, city)
    cities = city.split
    cities = ['helsinki', 'lappeenranta'] if cities.empty?

    temps = {}

    cities.each do |city|
      temp = get_temp(city)
      temps[city] = temp
    end

    str_length = cities.max {|a,b| a.length <=> b.length}.length

    if temps.all? {|city, temp| temp}
      temps.each do |city, temp|
        msg = "%-#{str_length+2}s %s" % [city.capitalize, temp]
        m.reply msg
        #m.reply "#{city.capitalize} #{temp}"
      end
    else
      m.reply "Paikkakuntaa '#{city}' ei löytynyt!"
    end
  end

  private

  def get_temp(city)
    @page = Nokogiri::HTML(open(URI::encode("http://ilmatieteenlaitos.fi/saa/#{city}")))
    #file = open(URI::encode("http://ilmatieteenlaitos.fi/saa/#{city}"))
    #content = file.read

    return nil unless @page.css("div[class='local-weather-error-message']").empty?
    temp = @page.css("table[class='observation-text']").css("span[class='parameter-name-value']")[0].children[2].text
  end
end
