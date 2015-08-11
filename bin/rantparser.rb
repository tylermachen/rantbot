require 'rest-client'
require 'sentimental'
require_relative '../phrases'
require 'pry'

class RantParser
  include Phrases::InstanceMethods

  @@rants = {
    :positive => [],
    :neutral => [],
    :negative => []
  }

  def initialize
    @analyzer = Sentimental.new
    Sentimental.load_defaults
    Sentimental.threshold = 0.0
    @power = "on"
    @commands = ["help", "list", "off"]
  end

  def help
    puts "Rantbot accepts the following commands:"
    puts "- help : displays this help menu"
    puts "- list : displays a list of all of your rants"
    puts "- off : turns off Rantbot"
  end

  def welcome
    puts '*---------------*'
    puts '│    RANTBOT    │'
    puts '│      ["]      │'
    puts '│     /[_]\     │'
    puts '│      ] [      │'
    puts '*---------------*'
  end

  def run
    welcome
    help
    until @power == "off"
      puts "Rant away..."
      input = get_user_input
      case input
        when 'help' then help
        when 'list' then list
        when 'off' then off
        else @sentiment = get_sentiment(input)
             puts return_phrase(@sentiment)
             @@rants[@sentiment] << input
      end
    end
  end

  def get_sentiment(input)
    @analyzer.get_sentiment(input)
  end

  def get_user_input
    input = gets.strip.downcase
  end

  def off
    puts "Talk to you never."
    @power = "off"
    abort
  end

  def list
    puts @@rants
  end
end

def create_playlist_hash
  url = "https://api.spotify.com/v1/search?type=playlist&q=#{mood}"
  # get the data from spotify's api
  spotify_json = RestClient.get(url)
  # make it readable by parsing it to json
  JSON.parse(spotify_json)
end

def analyze_hash
  hash = create_playlist_hash
  hash.values.first["items"].each do |playlist|
    name = playlist["name"]
    link = playlist["external_urls"].values.first
    track_count = playlist["tracks"]["total"]
    binding.pry
  end
end
analyze_hash

# rantbot = RantParser.new.run
