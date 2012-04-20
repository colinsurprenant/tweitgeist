$:.unshift File.dirname(__FILE__) + '/../../../'

require 'rubygems'
require 'redis/connection/hiredis'
require 'redis'
require 'thread'
require 'lib/tweitgeist/twitter/twitter_stream'
require 'config/twitter_reader'

module Tweitgeist

  class TwitterReader
    attr_accessor :config
    
    def initialize
      @redis = Redis.new(:host => "localhost", :port => 6379)
      @stats = Queue.new
      @flusher = detach_flusher
    end

    def start
      stream = TwitterStream.new(:path => '/1/statuses/sample.json', :auth => "#{CONFIG[:twitter_user]}:#{CONFIG[:twitter_pwd]}")
                  
      puts("twitter reader starting")

      tweet_count = 0
      start_time = Time.now.to_i
      stream.on_item do |item|
        @redis.rpush("twitter_stream", item)
        tweet_count += 1
        if tweet_count % 1000 == 0
          now = Time.now.to_i
          @stats << [tweet_count, now - start_time]
          start_time = now
        end
      end
      stream.on_error {|message| puts("stream error=#{message}")}
      stream.on_failure {|message| puts("stream failure=#{message}")}
      stream.on_reconnect {|timeout, retries| puts("stream reconnect timeout=#{timeout}, retries=#{retries}")}

      puts("opening stream connection")      
      stream.run
    end     

    private

    def detach_flusher
      Thread.new do
        Thread.current.abort_on_exception = true

        loop do
          stat = @stats.pop
          @redis.rpush("stream_rate", stat[0]/stat[1])
        end
      end
    end

  end
end

Tweitgeist::TwitterReader.new.start