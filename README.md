# Tweitgeist v1.2.0

Tweitgeist analyses the Twitter Spitzer hose and compute in realtime the top trending hashtags using [RedStorm](https://github.com/colinsurprenant/redstorm)/[Storm](https://github.com/nathanmarz/storm). What makes this interesting other than being a cool Storm example, is the fact that this architecture will work at **full Twitter Firehose scale** without much modifications. 

- See the [slideshare presentation](http://www.slideshare.net/colinsurprenant/twitter-big-data) about Twitter Big Data and Tweitgeist.
- See the live demo on [http://tweitgeist.colinsurprenant.com/](http://tweitgeist.colinsurprenant.com/)

There are three components:

- The Twitter Spitzer stream reader which pushes messages in a Redis queue
- The Redstorm analyser which read the Twitter stream queue, computes the trending hashtags and output the top N list every 5 seconds in a Redis queue
- The viewer UI for the visualization

## Dependencies

This has been tested on OSX 10.6+, Linux 11.10 & 12.04 using JRuby 1.6.x for the RedStorm topology and Ruby 1.9.x for the Twitter Spitzer hose reader.

## Installation

- [Redis](http://redis.io/) is required
- [RVM](http://beginrescueend.com/) is highly recommended as you will need to work with both Ruby/JRuby and different gemsets.

### Redstorm backend

- requires JRuby 1.6.x

- set JRuby in 1.9 mode by default

  ``` sh
  export JRUBY_OPTS=--1.9
  ```

- install the RedStorm gem using bundler with the supplied Gemfile

  ``` sh
  $ bundle install
  ```

- run RedStorm installation

  ``` sh
  $ bundle exec redstorm install
  ```

- package the topology required gems

  ``` sh
  $ bundle exec redstorm bundle topology
  ```

- if you plan on running the topology on a cluster, package the topology jar

  ``` sh
  bundle exec redstorm jar lib/tweitgeist/
  ```

### Twitter Spitzer stream reader

- requires Ruby 1.9.x

- install required gems using bundler with the supplied Gemfile

  ``` sh
  $ bundle install
  ```

### Viewer

- requires Node.js

  ``` sh
  $ sudo apt-get install nodejs
  ```

- requires npm

  ``` sh
  $ sudo apt-get install npm
  ```

- install CoffeeScript if you want to modify the Node.js server

  ``` sh
  $ npm install -g coffee-script
  ```

- install other dependencies

  ``` sh
  $ cd lib/viewer
  $ npm install .
  ```

## Usage overview

### Redstorm backend

- requires JRuby 1.6.x

- set JRuby in 1.9 mode by default

  ``` sh
  export JRUBY_OPTS=--1.9
  ```
 
#### RedStorm backend in **local** mode. 

``` sh
$ bundle exec redstorm local lib/tweitgeist/storm/tweitgeist_topology.rb
```

#### RedStorm backend in **remote cluster** mode.

- add your cluster info to `~/.storm/storm.yaml` see [setting up a Storm development environment](https://github.com/nathanmarz/storm/wiki/Setting-up-development-environment)

- make sure your locally installed storm distribution `bin/` directory is in your $PATH

``` sh
$  bundle exec redstorm cluster lib/tweitgeist/storm/tweitgeist_topology.rb
```


### Twitter Spitzer stream reader

- requires Ruby 1.9.x

- edit `config/twitter_reader.rb` to add your credentials

``` sh
$ ruby lib/tweitgeist/twitter/twitter_reader.rb
```

### Viewer

``` sh
$ coffee server.coffee --port 8080 --host 127.0.0.1 --redis-port 6379 --redis-host 127.0.0.1
```

or (with simulated data in case of no redis)

``` sh
$ coffee server.coffee --port 8080 --host 127.0.0.1 --mock
```


## Author
Colin Surprenant, [@colinsurprenant][twitter], [https://github.com/colinsurprenant][github], colin.surprenant@gmail.com

## Contributors
Francois Lafortune, [@quickredfox](http://twitter.com/quickredfox), [https://github.com/quickredfox](http://github.com/quickredfox), code@quickredfox.at

Nicholas Brochu, [@nbrochu](http://twitter.com/nbrochu), [https://github.com/nbrochu](http://github.com/nbrochu), info@nicholasbrochu.com

## License
Tweitgeist is distributed under the Apache License, Version 2.0. 

[twitter]: http://twitter.com/colinsurprenant
[github]: https://github.com/colinsurprenant
