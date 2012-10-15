require 'thread'

module Tweitgeist
  class RankBolt < RedStorm::SimpleBolt
    TOP_N = 10
    FLUSH_INTERVAL = 2

    on_init do
      @rankings = Hash.new
      @last = Time.now.to_i
      @rankings_lock = Mutex.new
      @flusher = detach_flusher
    end

    on_receive :emit => false do |tuple|
      hashtag, count  = tuple.getString(0), tuple.getLong(1)
      @rankings_lock.synchronize {@rankings[hashtag] = count}
    end

    private 

    def detach_flusher
      Thread.new do
        Thread.current.abort_on_exception = true
        sleep(FLUSH_INTERVAL)

        loop do
          sorted = nil
          @rankings_lock.synchronize do
            sorted = @rankings.sort{|a, b| b[1] <=> a[1]} # decreasing order on count
            @rankings.delete(sorted.pop[0]) while sorted.size > TOP_N 
          end
          unanchored_emit(sorted.to_json) unless sorted.empty?
            
          sleep(FLUSH_INTERVAL)
        end
      end
    end

  end
end
