require 'thread'

module Tweitgeist
  class RollingCounter
    attr_writer :active_bucket

    # @param bucket_count [Fixnum] buckets ring size 
    # @param bucket_seconds [Fixnum] bucket timeout in seconds
    # @param options [Hash] options
    # @option options [Boolean] :cleaner => false to disable automatic bucket expiration 
    # @yield [Object, Fixnum] call block upon bucket expiration with updated count for key
    def initialize(bucket_count, bucket_seconds, options = {}, &on_clean)
      @bucket_count = bucket_count
      @bucket_seconds = bucket_seconds
      @on_clean = on_clean
      @cleaner_thread = detach_cleaner if options[:cleaner] != false
      @counter = Hash.new{|h, k| h[k] = Array.new(bucket_count, 0)}
      @counter_lock = Mutex.new
      @active_bucket = nil
    end

    # @param key [Object] increment count by 1 for given key
    # @return [Fixnum] return the total count for given key
    def add(key)
      @counter_lock.synchronize do
        @counter[key][active_bucket] += 1
        @counter[key].reduce(:+)
      end
    end

    # @param key [Object] key for required count
    # @return [Fixnum] return the total count for given key
    def count(key)
      @counter_lock.synchronize do
        @counter[key].reduce(:+)
      end
    end

    # zero bucket for all keys, delete useless keys, fire callbacks for any changed key
    # @param clean_bucket [Fixnum] bucket number to clean
    def clean(clean_bucket)
      callbacks = []
      zeroed = []

      @counter_lock.synchronize do
        @counter.each do |key, buckets|
          saved_count = buckets[clean_bucket]
          buckets[clean_bucket] = 0
          total = buckets.reduce(:+)
          callbacks << [key, total] unless saved_count.zero?
          zeroed << key if total.zero?
        end

        # delete keys outside the hash iteration
        zeroed.each{|key| @counter.delete(key)}
      end

      # execute callbacks outside synchronize block
      callbacks.each{|key, total| @on_clean.call(key, total) if @on_clean}
    end

    # @return [Fixnum] return set active_bucket or calc from current time
    def active_bucket
      @active_bucket || (Time.now.to_i / @bucket_seconds) % @bucket_count
    end

    private

    def detach_cleaner
      Thread.new do
        Thread.current.abort_on_exception = true

        last_bucket = active_bucket

        loop do
          if (current_bucket = active_bucket) != last_bucket
            next_bucket = (current_bucket + 1) % @bucket_count
            clean(next_bucket)
            last_bucket = current_bucket
          end

          sleep(1)
        end
      end
    end


  end
end