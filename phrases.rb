module Phrases
  module InstanceMethods
    def return_phrase(sentiment)
      phrases = {
        :positive => ["Great to hear!"],
        :neutral => ["You should get more emotional."],
        :negative => ["Sucks to be you...",
                      "Sounds like a personal problem.",
                      "Can't help you there.",
                      "Sounds like you need professional help."]
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
