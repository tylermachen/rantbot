require 'rest-client'
require 'sentimental'
require 'nokogiri'
require 'open-uri'
require 'launchy'
require 'pry'

class RantParser
  PROMPT = "> "
  SLEEP_DURATION = 5
  INSULT_LIMIT = 5
  RANDOM_NUM = rand(1..6)
  @@gifs = { :cats => ["http://cdn.newadnetwork.com/sites/prod/files/uploads/joellec/expedition.gif",
                      "http://i.imgur.com/v5NjWGk.gif",
                      "https://s-media-cache-ak0.pinimg.com/originals/fb/fe/ef/fbfeef7116a928b29a92bc4bd38bfd49.gif"],
             :dogs => ["http://static.tumblr.com/q8dfwso/cTOm7x5ih/puppies.gif",
                      "http://33.media.tumblr.com/tumblr_me1154L3aY1r67nlm.gif",
                      "http://mtv.mtvnimages.com/uri/mgid:file:http:shared:mtv.com/news/wp-content/uploads/2015/03/cutepuppy-1426855748.gif"],
             :rabbit => ["https://sociorocketnewsen.files.wordpress.com/2014/07/cup-of-bunnies.gif?w=580",
                        "https://31.media.tumblr.com/f425df224967cb0b16d943c317cabb8b/tumblr_ne0z6kqf9o1te5ruso1_500.gif",
                        "https://31.media.tumblr.com/12aae17647a47298acb70eb57f3138e2/tumblr_n3l299jAvf1so0ukuo1_500.gif"],
             :pandas => ["http://cdn.funnyhub.com/2015/feb/pandas/pandas20.gif",
                        "http://media.giphy.com/media/2rJSj83iGYN8c/giphy.gif",
                        "https://s-media-cache-ak0.pinimg.com/originals/ea/8e/dd/ea8edd78de11beb9fe595780b7683c22.gif"]
  }
  @@insults = []
  @@insult_counter = 0
  @@rants = {
    :positive => [],
    :negative => [],
    :neutral => []
  }

  def initialize
    @analyzer = Sentimental.new
    Sentimental.load_defaults
    Sentimental.threshold = 0.0
    @power = "on"
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
             insult = get_insults
             puts "\n#{insult}"
             @@insults << insult
             @@insult_counter += 1
             @@rants[@sentiment] << input
             if @@insult_counter == INSULT_LIMIT
               if (1..2).include?(RANDOM_NUM)
                 playlist_link = analyze_hash
                 Launchy.open("#{playlist_link}")
               elsif (3..6).include?(RANDOM_NUM)
                 # refactor
                 gif_url = @@gifs.values.shuffle.first.shuffle.first
                 Launchy.open("#{gif_url}")
               end
               @@insult_counter = 0
             end
      end
    end
  end

  def create_playlist_hash
    url = "https://api.spotify.com/v1/search?type=playlist&q=happy"
    spotify_json = RestClient.get(url)
    JSON.parse(spotify_json)
  end

  def analyze_hash
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
    puts "\n#{@name.capitalize}"
    puts "#{@playlist_link}"
    @playlist_link
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
    puts "\nExporting...\n\n"
    sleep(SLEEP_DURATION)
    puts "All done!"
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

  def get_insults
    url = "http://www.insultgenerator.org/"
    html = open(url).read
    doc = Nokogiri::HTML(html)
    insult = doc.css("div.wrap").text.gsub(/\n/, '')
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

  def get_user_input
    gets.strip.downcase.gsub(/[!?.,;:]$/, '')
  end

  def insults
    @@insults
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

rantbot = RantParser.new.run
