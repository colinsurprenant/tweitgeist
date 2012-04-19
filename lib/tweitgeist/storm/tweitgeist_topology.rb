require 'rubygems'      # required for remote cluster exec where TopolyLauncher + require rubygems is not called
require 'red_storm'     # must be required before bundler for environment setup and after rubygems

require 'lib/tweitgeist/storm/twitter_stream_spout'
require 'lib/tweitgeist/storm/extract_message_bolt'
require 'lib/tweitgeist/storm/extract_hashtags_bolt'
require 'lib/tweitgeist/storm/rolling_count_bolt'
require 'lib/tweitgeist/storm/rank_bolt'
require 'lib/tweitgeist/storm/merge_bolt'

module Tweitgeist
 
  class TweitgeistTopology < RedStorm::SimpleTopology
    spout TwitterStreamSpout
        
    bolt ExtractMessageBolt, :parallelism => 3 do
      source TwitterStreamSpout, :shuffle
    end

    bolt ExtractHashtagsBolt, :parallelism => 3 do
      source ExtractMessageBolt, :shuffle
    end

    bolt RollingCountBolt, :parallelism => 3 do
      source ExtractHashtagsBolt, :fields => ["hashtag"]
    end

    bolt RankBolt, :parallelism => 3 do
      source RollingCountBolt, :fields => ["hashtag"]
    end

    bolt MergeBolt, :parallelism => 1 do
      source RankBolt, :global
    end

    configure do |env|
      case env
      when :local
        debug false
        max_task_parallelism 10
      when :cluster
        debug true
        num_workers 20
        max_spout_pending(1000);
      end
    end
  end
end