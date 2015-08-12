module Phrases
  module InstanceMethods
    def return_phrase(sentiment)
      phrases = {
        :positive => ["Great to hear!",
                      "Colorful clay loves to love."],
        :neutral => ["You should get more emotional.",
                     "Stupidity is good for you.",
                     "A small mercy is like a summer breeze.",
                     "Passion or serendipity sat down once more.",
                     "A passionate evening takes the world for granted.",
                     "Whiskey on the table is nonsensical, much like me.",
                     "That stolen figurine is not yet ready to die."],
        :negative => ["Sucks to be you...",
                      "Sounds like a personal problem.",
                      "Can't help you there.",
                      "Sounds like you need professional help.",
                      "A setback of the heart is a storyteller without equal.",
                      "The person you were before is often one floor above you.",
                      "An old apple is good for you.",
                      "Another day jumps both ways."]
      }
      phrases[sentiment].sample
    end
  end
end

 # moods:
 # "happy"
 # "angry"
 # "sad"
 # "relaxing"
 # "excited"
