require 'rest-client'
require 'sentimental'
require 'nokogiri'
require 'open-uri'
require 'launchy'
require_relative '../lib/hashdata'
require 'pry'

class RantBot
  include HashData::InstanceMethods
  PROMPT = "> "
  SLEEP_DURATION = 3
  INSULT_LIMIT = 5

  def initialize
    @analyzer = Sentimental.new
    Sentimental.load_defaults
    Sentimental.threshold = 0.0
    @power = "on"
    @insult_counter = 0
    @random_num = get_random_num
    @insults = []
    @rants = {
      :positive => [],
      :negative => [],
      :neutral => []
    }
  end

  def run
    welcome
    help
    until @power == "off"
      puts "\nRant away..."
      print PROMPT
      input = get_user_input
      case input
        when 'help' then help
        when 'list' then list
        when 'off' then off
        when 'export' then export
        when 'insults' then insults
        when 'exit' then off
        else @sentiment = get_sentiment(input)
             @rants[@sentiment] << input
             return_insult
             if @insult_counter == INSULT_LIMIT
               show_love
               @random_num = get_random_num
               @insult_counter = 0
             end
      end
    end
  end

  def welcome
    puts "\nHey friend, I'm RantBot."
    puts "Tell me how you feel and I'll make your day better!\n"
    puts '*---------------------------------------*'
    puts '│                RANTBOT                │'
    puts '│                  ["]                  │'
    puts '│                 /[_]\                 │'
    puts '│                  ] [                  │'
    puts '*---------------------------------------*'
  end

  def help
    puts "\nRantbot accepts the following commands:"
    puts "- off     : turns off Rantbot"
    puts "- help    : displays this help menu"
    puts "- list    : displays a list of all of your rants"
    puts "- export  : exports your rants to a text file"
    puts "- insults : shows you what you deserve..."
  end

  def show_love
    if (1..2).include?(@random_num)
      playlist_link = return_spotify_link
      Launchy.open("#{playlist_link}")
    elsif (4..5).include?(@random_num)
      gifs = return_gif_hash
      gif_url = gifs.values.shuffle.first.shuffle.first
      Launchy.open("#{gif_url}")
    elsif (5..6).include?(@random_num)
      youtube_url = "https://www.youtube.com/embed/s2RLgY_Z8To"
      Launchy.open("#{youtube_url}")
    end
  end

  def create_playlist_hash
    url = "https://api.spotify.com/v1/search?type=playlist&q=happy"
    spotify_json = RestClient.get(url)
    JSON.parse(spotify_json)
  end

  def return_spotify_link
    hash = create_playlist_hash
    hash.values.first["items"].shuffle.each do |playlist|
        @name = playlist["name"]
        @playlist_link = playlist["external_urls"]["spotify"]
        @track_count = playlist["tracks"]["total"]
    end
    sleep(SLEEP_DURATION)
    puts "\nOkay okay, that was a little mean..."
    sleep(SLEEP_DURATION)
    puts "\nHere's a playlist with " +
         "#{@track_count} songs to cheer you up!"
    puts "\n#{@name.capitalize} Playlist:"
    puts "#{@playlist_link}"
    @playlist_link
  end
=begin
  def apologize()
    sleep(SLEEP_DURATION)
    puts "\nOkay okay, that was a little mean..."
    sleep(SLEEP_DURATION)
    puts "\nHere's a playlist with " +
         "#{track_count} songs to cheer you up!"
    puts "\n#{name.capitalize}"
    puts "#{playlist_link}"
  end
=end
  def export
    File.open('./rants/my-rants.txt', 'w') do |file|
      file.puts "MY RANTS"
      file.puts "---------------------"
      @rants.each do |key, value|
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
    puts "\nExporting...\n\n"
    sleep(SLEEP_DURATION)
    puts "All done!"
  end

  def list
    @rants.each do |key, value|
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

  def return_insult
    url = "http://www.insultgenerator.org/"
    html = open(url).read
    doc = Nokogiri::HTML(html)
    insult = doc.css("div.wrap").text.gsub(/\n/, '')
    @insults << insult
    @insult_counter += 1
    puts "\n#{insult}"
  end

  def get_user_input
    gets.strip.downcase.gsub(/[!?.,;:]$/, '')
  end

  def get_random_num
    rand(1..6)
  end

  def insults
    @insults
  end

  def get_sentiment(input)
    @analyzer.get_sentiment(input)
  end

  def off
    puts "\nTalk to you never.\n\n"
    @power = "off"
    abort
  end
end

rantbot = RantBot.new.run
