require_relative '../config/environment.rb'

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
    @rants = []
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
        when 'rant' then rant
        when 'look' then look_at_rantbot
        when 'off' then off
        when 'export' then export
        when 'insults' then display_insults
        when 'exit' then off
        else @rants << input
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
    puts "\n*~--------------------------------------~*"
    puts "│                RANTBOT                 │"
    puts '│                  ["]                   │'
    puts '│                 /[♥]\                  │'
    puts "│                  ] [                   │"
    puts "*~--------------------------------------~*"
    puts "\nHey friend, I'm RantBot."
    puts "Tell me how you feel and I'll make your day better!\n"
  end

  def help
    puts "\nRantbot accepts the following commands:"
    puts "---------------------------------------"
    puts "- off     : turns off Rantbot"
    puts "- help    : displays this help menu"
    puts "- rant    : displays your entire rant"
    puts "- look    : look at RantBot"
    puts "- export  : exports your rant to a text file"
    puts "- insults : shows you what you deserve..."
  end

  def show_love
    if (1..2).include?(@random_num)
      return_spotify
    elsif (4..5).include?(@random_num)
      return_gif
    elsif (5..6).include?(@random_num)
      return_youtube
    end
  end

  def return_gif
    puts "\nGet over yourself. Here..."
    sleep(SLEEP_DURATION)
    gifs = return_gif_hash
    gif_url = gifs.values.shuffle.first.shuffle.first
    Launchy.open("#{gif_url}")
  end

  def return_youtube
    puts "\nAlright alright, here's something you'll enjoy..."
    sleep(SLEEP_DURATION)
    youtube_url = "https://www.youtube.com/embed/s2RLgY_Z8To"
    Launchy.open("#{youtube_url}")
  end

  def create_playlist_hash
    url = "https://api.spotify.com/v1/search?type=playlist&q=happy"
    spotify_json = RestClient.get(url)
    JSON.parse(spotify_json)
  end

  def return_spotify
    hash = create_playlist_hash
    hash.values.first["items"].shuffle.each do |playlist|
        @name = playlist["name"]
        @playlist_link = playlist["external_urls"]["spotify"]
        @track_count = playlist["tracks"]["total"]
    end
    puts "\nOkay okay, that was a little harsh..."
    sleep(SLEEP_DURATION)
    puts "\nHere's a playlist with " +
         "#{@track_count} songs to cheer you up!"
    puts "\n#{@name.capitalize} playlist:"
    puts "#{@playlist_link}"
    sleep(SLEEP_DURATION)
    Launchy.open("#{@playlist_link}")
  end

  def export
    if @rants.count > 0
      File.open('./rants/my-rants.txt', 'w') do |file|
        file.puts "\n*---------------------*"
        file.puts "│      Your Rant      │"
        file.puts "*---------------------*\n\n"
        @rants.each do |rant|
            file.print "#{rant.capitalize}. "
        end
        file.puts "\n"
        puts "\nExporting...\n\n"
        sleep(SLEEP_DURATION)
        puts "All done!"
      end
    else
      puts "\nThere is nothing to export yet."
    end
  end

  def rant
    if @rants.count > 0
      puts "\n*---------------------*"
      puts "│      Your Rant      │"
      puts "*---------------------*\n\n"
      @rants.each do |rant|
          print "#{rant.capitalize}. "
      end
      puts "\n"
    else
      puts "\nYou have not ranted yet."
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

  def display_insults
    if @insults.count > 0
      puts "\n*---------------------------------*"
      puts "│    Just In Case You Forgot...   │"
      puts "*---------------------------------*\n\n"
      @insults.each do |insult|
        puts "- #{insult}\n\n"
      end
    else
      puts "\nYou have not been insulted yet."
    end
  end

  def get_sentiment(input)
    @analyzer.get_sentiment(input)
  end

  def look_at_rantbot
    quote = return_rantbot_quote.sample
    puts "\n            RANTBOT  "
    puts '              ["]    '
    puts '             /[♥]\   '
    puts "              ] [    - #{quote}"
  end

  def off
    puts "\nTalk to you never.\n\n"
    @power = "off"
    abort
  end
end

rantbot = RantBot.new.run
