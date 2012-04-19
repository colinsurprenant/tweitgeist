require 'twitter/json_stream'
require 'eventmachine'

module Tweitgeist

  class TwitterStream
    
    def initialize(options = {})
      @options = options
      
      # default empty handlers
      @on_item = lambda{|item|}
      @on_close = lambda{}
      @on_error = lambda{|message|}
      @on_failure = lambda{|message|}
      @on_reconnect= lambda{|timeout, retries|}
      @stream = nil
    end
    
    def on_item(&block)
      @on_item = lambda do |item|
        begin
          block.call(item)
        rescue
          stop
          @on_failure.call("on_item exception #{$!.message}, #{$!.backtrace.join("\n")}")
        end
      end
    end
    
    def on_close(&block)
      @on_close = lambda do
        begin
          block.call
        rescue
          stop
          @on_failure.call("on_close exception=#{$!.inspect}\n#{$!.backtrace.join("\n")}")
        end
      end
    end

    def on_error(&block)
      @on_error = lambda do |message|
        begin
          block.call(message)
        rescue
          stop
          @on_failure.call("on_error exception=#{$!.inspect}\n#{$!.backtrace.join("\n")}")
        end
      end
    end
    
    def on_reconnect(&block)
      @on_reconnect = lambda do |timeout, retries|
        begin
          block.call(timeout, retries)
        rescue
          stop
          @on_failure.call("on_item exception=#{$!.inspect}\n#{$!.backtrace.join("\n")}")
        end
      end
    end
    
    def on_failure(&block)
      @on_failure = lambda do |message|
        begin
          block.call(message)
        rescue
          stop
          puts("on_failure exception=#{$!.inspect}\n#{$!.backtrace.join("\n")}")
        end
      end
    end
    
    def stop
      EventMachine.stop_event_loop if EventMachine.reactor_running? 
    end
    
    def run
      EventMachine.run do
        @stream = Twitter::JSONStream.connect(@options)
    
        # attach callbacks to EM stream
        @stream.each_item(&@on_item)
        @stream.on_close(&@on_close)
        @stream.on_error(&@on_error)
        @stream.on_reconnect(&@on_reconnect)
        @stream.on_max_reconnects{|timeout, retries| @on_failure.call("failed after max reconnect=#{retries.to_s} using timeout=#{timeout.to_s}")}
      end
    end
    
  end

end
