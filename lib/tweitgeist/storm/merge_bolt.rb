require 'redis'

module Tweitgeist
  class MergeBolt < RedStorm::SimpleBolt
    TOP_N = 10
    PUSH_INTERVAL = 5
    HISTORY_SIZE = (24*60*60)/PUSH_INTERVAL # 24h

    on_init do
      @rankings = Hash.new
      @last_time = Time.now.to_i
      @redis = Redis.new(:host => "localhost", :port => 6379)
    end

    on_receive :emit => false do |tuple|
      # tuple is [[hashtag1, count1], [hashtag2, count2], ...]
      update = Hash[*JSON.parse(tuple.getString(0)).flatten]

      @rankings.merge!(update)
      sorted = @rankings.sort{|a, b| b[1] <=> a[1]} # decreasing order on count
      @rankings.delete(sorted.pop[0]) while sorted.size > TOP_N 

      # poor's man delayed push, ok since we receive 'infrequent' tuples
      if (now = Time.now.to_i) > (@last_time + PUSH_INTERVAL)
        @last_time = now
        unless sorted.empty?
          @redis.pipelined do
            @redis.rpush('rankings', sorted.to_json)

            @redis.lpush('past_rankings', {'created_at' => now, 'rankings' => sorted}.to_json)
            @redis.ltrim('past_rankings', 0, HISTORY_SIZE - 1)
          end
        end
      end
    end

  end
end
