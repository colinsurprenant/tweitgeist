# Tweitgeist v1.0.0

Tweitgeist analyses the Twitter Spitzer hose and compute in realtime the top trending hashtags using [RedStorm](https://github.com/colinsurprenant/redstorm)/[Storm](https://github.com/nathanmarz/storm). What makes this interesting other than being a cool Storm example, is the fact that this architecture will work at **full Twitter Firehose scale** without much modifications. 

- See the [slideshare presentation](http://www.slideshare.net/colinsurprenant/twitter-big-data) about Twitter Big Data and Tweitgeist.
- See the live demo on [http://tweitgeist.needium.com/](http://tweitgeist.needium.com/)

There are three components:

- The Twitter Spitzer stream reader which pushes messages in a Redis queue
- The Redstorm analyser which read the Twitter stream queue, computes the trending hashtags and output the top N list every 5 seconds in a Redis queue
- The viewer UI for the visualization

## Dependencies

This has been tested on OSX 10.6.8, Linux 11.10 using JRuby 1.6.7 for the RedStorm topology and Ruby 1.9.2 for the Twitter Spitzer hose reader.

## Installation

- [Redis](http://redis.io/) is required
- [RVM](http://beginrescueend.com/) is highly recommended as you will need to work with both Ruby/JRuby and different gemsets.

### Redstorm backend

- requires JRuby 1.6
- install [RedStorm](https://github.com/colinsurprenant/redstorm)
- install redis gem
- install json gem
- install rake gem

### Twitter Spitzer stream reader

- requires Ruby 1.9.2
- install twitter-stream gem
- install redis gem
- install hiredis gem

### Viewer

- requires Node.js
- requires npm 
- install CoffeeScript if you want to modify the Node.js server

## Usage overview

### Redstorm backend

The RedStorm backend has only been tested in "local" mode. 

``` sh
$ redstorm local lib/tweitgeist/storm/tweitgeist_topology.rb 
```

### Twitter Spitzer stream reader

- modify config/twitter_reader.rb

``` sh
$ ruby lib/tweitgeist/twitter/twitter_reader.rb
```

### Viewer

``` sh
$ coffee server.coffee --port 6000 --host locahost --redis-port 1234 --redis-host 127.0.0.1
```

or (with simulated data in case of no redis)

``` sh
$ coffee server.coffee --port 6000 --host locahost --mock
```


## Author
Colin Surprenant, [@colinsurprenant][twitter], [https://github.com/colinsurprenant][github], colin.surprenant@needium.com, colin.surprenant@gmail.com

## Contributors
Francois Lafortune, [@quickredfox](http://twitter.com/quickredfox), [https://github.com/quickredfox](http://github.com/quickredfox), code@quickredfox.at

Nicholas Brochu, [@nbrochu](http://twitter.com/nbrochu), [https://github.com/nbrochu](http://github.com/nbrochu), info@nicholasbrochu.com

## License
Tweitgeist is distributed under the Apache License, Version 2.0. 

[twitter]: http://twitter.com/colinsurprenant
[github]: https://github.com/colinsurprenant
