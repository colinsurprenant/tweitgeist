require 'json'

module Tweitgeist
  class ExtractHashtagsBolt < RedStorm::SimpleBolt
    on_receive do |tuple|
      hashtags = tuple.getString(0).split.select{|w| w[0] == '#' && w.size > 3}.map{|w| [w.upcase]}
      hashtags.empty? ? nil : hashtags
    end
  end
end
