require 'redis'
require 'thread'

module Tweitgeist

  class TwitterStreamSpout < RedStorm::SimpleSpout
    on_send {@q.pop if @q.size > 0}

    on_init do
      @q = Queue.new
      @redis_reader = detach_redis_reader
    end
    
    private

    def detach_redis_reader
      Thread.new do
        Thread.current.abort_on_exception = true

        redis = Redis.new(:host => "localhost", :port => 6379)
        loop do
          if data = redis.blpop("twitter_stream", 0)
            @q << data[1]
          end
        end
      end
    end
    
  end
end