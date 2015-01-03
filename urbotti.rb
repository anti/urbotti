require 'cinch'
require 'redis'
require 'open-uri'
require 'json'
require 'curb'
require 'nokogiri'
require 'yaml'

# Load configure
config = YAML::load_file('config.yml')

# Load plugins
require_relative 'plugins/links.rb'
require_relative 'plugins/weather.rb'
require_relative 'plugins/talkative.rb'
require_relative 'plugins/worldcup.rb'
require_relative 'plugins/open_weather_map.rb'
require_relative 'plugins/google.rb'

trap(:INT) { puts; exit }

bot = Cinch::Bot.new do
  configure do |c|
    c.server        = config["server"]
    c.port          = config["port"]
    c.ping_interval = config["ping_interval"]
    c.realname      = config["realname"]
    c.user          = config["user"]
    c.nick          = config["nick"]
    c.channels      = config["channels"]

    c.plugins.prefix = ""
    c.plugins.plugins = [Links, Weather, Talkative, OpenWeatherMap, Google]
  end

end

bot.start
