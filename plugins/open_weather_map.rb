require "net/https"
require "uri"
require 'json'

class OpenWeatherMap
  include Cinch::Plugin

  match /!weather\s?(.*)/, :method => :get_weather

  def get_weather(m, cities)
    cities = cities.split(';')
    cities = ['helsinki', 'lappeenranta'] if cities.empty?

    messages = cities.map { |city| query(city) }
    messages.each { |message| m.reply message }
  end

  private

    def query(city)
      uri = URI.parse(URI.escape("http://api.openweathermap.org/data/2.5/weather?q=#{city}&units=metric&lang=fi"))
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)

      result = JSON.parse(response.body)

      if result["cod"] == "404"
        "Kaupunkia '#{city.capitalize}' ei löytynyt!"
      else
        name = result["name"]
        country = result["sys"]["country"]
        temp = result["main"]["temp"].to_f.round(2)
        min = result["main"]["temp_min"]
        max = result["main"]["temp_max"]

        wind = result["wind"]["speed"]

        text = result["weather"][0]["description"]
        "#{city.capitalize}, #{name}, #{country} #{temp}°C, #{wind} m/s, #{text}"
      end
    end

end
