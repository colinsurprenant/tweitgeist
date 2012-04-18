require 'json'
require 'lib/redwatch/rolling_counter'

module Redwatch
  class RollingCountBolt < RedStorm::SimpleBolt
    output_fields :hashtag, :count

    on_init do
      # 30 buckets of 10 seconds
      @counter = RollingCounter.new(60, 10) {|hashtag, count| unanchored_emit(hashtag, count)}
    end

    on_receive do |tuple|
      hashtag = tuple.getString(0)
      count = @counter.add(hashtag)
      [hashtag, count]
    end
  end
end
