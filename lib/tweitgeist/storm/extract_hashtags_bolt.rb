require 'json'
require 'twitter-text'

module Tweitgeist
  class ExtractHashtagsBolt < RedStorm::SimpleBolt
    include Twitter::Extractor

    on_receive do |tuple|
      hashtags = extract_hashtags(tuple.getString(0)).select{|h| h.size > 3}.map{|h| ["##{h.upcase}"]}
      hashtags.empty? ? nil : hashtags
    end
  end
end
