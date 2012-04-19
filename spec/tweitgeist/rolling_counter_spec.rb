require 'spec_helper'
require 'tweitgeist/rolling_counter'

describe Tweitgeist::RollingCounter do

  it "should initialize" do
    rc = Tweitgeist::RollingCounter.new(3, 10)
    rc = Tweitgeist::RollingCounter.new(3, 10, {:cleaner => false})
    rc = Tweitgeist::RollingCounter.new(3, 10, {:cleaner => false}) {puts("hello")}
    rc = Tweitgeist::RollingCounter.new(3, 10) {puts("hello")}
  end

  it "should add with single bucket" do
    rc = Tweitgeist::RollingCounter.new(3, 10, {:cleaner => false})
    rc.active_bucket = 0

    rc.count("foo").should == 0
    rc.add("foo").should == 1
    rc.add("foo").should == 2

    rc.count("bar").should == 0
    rc.add("bar").should == 1
    rc.add("bar").should == 2
  end

  it "should add with multiple buckets" do
    rc = Tweitgeist::RollingCounter.new(3, 10, {:cleaner => false})

    rc.active_bucket = 0
    rc.count("foo").should == 0
    rc.add("foo").should == 1
    rc.add("foo").should == 2

    rc.count("bar").should == 0
    rc.add("bar").should == 1
    rc.add("bar").should == 2

    rc.active_bucket = 1
    rc.count("foo").should == 2
    rc.add("foo").should == 3
    rc.add("foo").should == 4

    rc.count("bar").should == 2
    rc.add("bar").should == 3
    rc.add("bar").should == 4
  end

  it "should clean bucket" do
    rc = Tweitgeist::RollingCounter.new(3, 10, {:cleaner => false})

    rc.active_bucket = 0
    rc.count("foo").should == 0
    rc.add("foo").should == 1
    rc.add("foo").should == 2

    rc.count("bar").should == 0
    rc.add("bar").should == 1
    rc.add("bar").should == 2

    rc.active_bucket = 1
    rc.count("foo").should == 2
    rc.add("foo").should == 3
    rc.add("foo").should == 4

    rc.count("bar").should == 2
    rc.add("bar").should == 3
    rc.add("bar").should == 4

    rc.active_bucket = 2
    rc.count("foo").should == 4
    rc.add("foo").should == 5
    rc.add("foo").should == 6

    rc.count("bar").should == 4
    rc.add("bar").should == 5
    rc.add("bar").should == 6

    rc.clean(0)
    rc.count("foo").should == 4
    rc.count("bar").should == 4

    rc.clean(1)
    rc.count("foo").should == 2
    rc.count("bar").should == 2

    rc.clean(2)
    rc.count("foo").should == 0
    rc.count("bar").should == 0
  end

  it "should call on_clean" do
    cleaned = []
    rc = Tweitgeist::RollingCounter.new(3, 10, {:cleaner => false}) {|key, total| cleaned << [key, total]}

    rc.active_bucket = 0
    rc.add("foo").should == 1
    rc.add("foo").should == 2
    rc.add("bar").should == 1
    rc.add("bar").should == 2
    rc.clean(0)
    cleaned.should == [["foo", 0], ["bar", 0]]

    cleaned = []
    rc.active_bucket = 0
    rc.add("foo").should == 1
    rc.add("foo").should == 2
    rc.add("bar").should == 1
    rc.add("bar").should == 2

    rc.active_bucket = 1
    rc.add("foo").should == 3
    rc.add("foo").should == 4
    rc.add("bar").should == 3
    rc.add("bar").should == 4

    rc.clean(0)
    cleaned.should == [["foo", 2], ["bar", 2]]
  end

end
