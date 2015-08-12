require 'rest-client'
require 'sentimental'
require 'nokogiri'
require 'open-uri'
require_relative './phrases'
require 'pry'

class RantParser
  include Phrases::InstanceMethods

  @@rants = {
    :positive => [],
    :negative => [],
    :neutral => []
  }

  @@prompt = "> "

  def initialize
    @analyzer = Sentimental.new
    Sentimental.load_defaults
    Sentimental.threshold = 0.0
    @power = "on"
    @commands = ["help", "list", "off", "export"]
  end

  def help
    puts "\n"
    puts "Rantbot accepts the following commands:"
    puts "- help   : displays this help menu"
    puts "- list   : displays a list of all of your rants"
    puts "- export : exports your rants to a text file"
    puts "- off    : turns off Rantbot"
  end

  def welcome
    puts "RantBot knows how you feel and knows how to make your day better."
    puts "\n"
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
      puts "\nRant away..."
      print @@prompt
      input = get_user_input
      case input
        when 'help' then help
        when 'list' then list
        when 'off' then off
        when 'export' then export
        else @sentiment = get_sentiment(input)
             puts "\n"
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
    puts "\nTalk to you never.\n\n"
    @power = "off"
    abort
  end

  def export
    File.open('./rants/my-rants.txt', 'w') do |file|
      file.puts "MY RANTS"
      file.puts "---------------------"
      @@rants.each do |key, value|
        unless value.empty?
          file.puts "---------------------"
          file.puts "   #{key.capitalize} Rant"
          file.puts "---------------------"
          value.each do |rant|
            file.print "#{rant.capitalize}. "
          end
          file.puts "\n\n"
        end
      end
    end
  end

  def list
    @@rants.each do |key, value|
      unless value.empty?
        puts "---------------------"
        puts "   #{key.capitalize} Rant"
        puts "---------------------"
        value.each do |rant|
          print "#{rant.capitalize}. "
        end
        puts "\n\n"
      end
    end
  end
end

def get_insults
  url = ""
  html = open(url).read
  doc = Nokogiri::HTML(html)
end

def create_playlist_hash
  url = "https://api.spotify.com/v1/search?type=playlist&q=happy"
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
    image_link = playlist["images"].first["url"]
  end
end

rantbot = RantParser.new.run
