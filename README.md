# Redwatch v0.0.1

Redwatch analyses the Twitter Spitzer hose and compute in realtime the top trending hashtags using [RedStorm](https://github.com/colinsurprenant/redstorm)/[Storm](https://github.com/nathanmarz/storm).

There are three components:

- The Twitter Spitzer stream reader which pushes messages in a Redis queue

- The Redstorm analyser which read the Twitter stream queue, computes the trending hashtags and output the top N list every 5 seconds in a Redis queue

- The viewer UI for the visualization

## Dependencies

This has been tested on OSX 10.6.8, Linux 11.10 using JRuby 1.6.7 for the RedStorm topology and Ruby 1.9.2 for the Twitter Spitzer hose reader.

## Installation

- A [Redis](http://redis.io/) server is required
- [RVM](http://beginrescueend.com/) is highly recommended as you will need to work with both Ruby/JRuby and different gemsets.

### Redstorm backend

- requires JRuby 1.6

- install [RedStorm](https://github.com/colinsurprenant/redstorm)

- install redis gem
- install json gem
- install rake gem

### Twitter Spitzer stream reader

- required Ruby 1.9.2

- install twitter-stream gem
- install redis gem

### Twitter Spitzer stream reader

- requires node.js, npm, CoffeeScript

see the [viewer README](https://github.com/colinsurprenant/redwatch/tree/master/lib/viewer)

## Usage overview

### Redstorm backend

The RedStorm backend has only been tested in "local" mode. 

``` sh
$ redstorm local lib/redwatch/storm/redwatch_topology.rb 
```

### Twitter Spitzer stream reader

``` sh
$ ruby lib/redwatch/twitter/twitter_reader.rb
```

### Twitter Spitzer stream reader

see the [viewer README](https://github.com/colinsurprenant/redwatch/tree/master/lib/viewer)

## Author
Colin Surprenant, [@colinsurprenant][twitter], [http://github.com/colinsurprenant][github], colin.surprenant@needium.com, colin.surprenant@gmail.com

## Contributors
Francois Lafortune, [@quickredfox](http://twitter.com/quickredfox), [http://github.com/quickredfox](http://github.com/quickredfox), code@quickredfox.at

Nicolas Brochu, [@nbrochu](http://twitter.com/nbrochu), [http://github.com/nbrochu](http://github.com/nbrochu), info@nicholasbrochu.com

## License
Redwatch is distributed under the Apache License, Version 2.0. 

[twitter]: http://twitter.com/colinsurprenant
[github]: http://github.com/colinsurprenant
