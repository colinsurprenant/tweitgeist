require 'redis'

module Redwatch
  class MergeBolt < RedStorm::SimpleBolt
    output_fields :json_rankings

    TOP_N = 10
    PUSH_INTERVAL = 10

    on_init do
      @rankings = Hash.new
      @last = Time.now.to_i
      @redis = Redis.new(:host => "localhost", :port => 6379)
    end

    on_receive :emit => false do |tuple|
      merge = JSON.parse(tuple.getString(0))

      merge.each{|key, count| @rankings[key] = count}
      sorted = @rankings.sort{|a, b| b[1] <=> a[1]} # decreasing order on count
      @rankings.delete(sorted.pop[0]) while sorted.size > TOP_N 
      if (now = Time.now.to_i) > (@last + PUSH_INTERVAL)
        @last = now
        @redis.rpush("rankings", sorted.to_json) unless sorted.empty? 
      end
    end
  end
end
