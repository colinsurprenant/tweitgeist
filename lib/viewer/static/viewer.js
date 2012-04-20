$.holdReady(true);

var colorsets = null
    , pollstate  = 0
    , polldelay = 3000
    , mappedColors = {}
    , fetchcolorsets = $.getJSON('colorsets.json');

fetchcolorsets.fail(function() {
  throw "Cannot load essential data.";
});

fetchcolorsets.done(function(json) {
  colorsets = json;
  return $.holdReady(false);
});

var getMappingForString = function(string) {
  if (!mappedColors[string]) {
    mappedColors[string] = colorsets.map[colorsets.hex[Math.floor(Math.random() * colorsets.hex.length)]];
  }
  return mappedColors[string];
};

var decorate = function( json ) {
  // pre calculate real total of all counts
  var real_total = 0;
  json.reduce( function( mod, pair ) {
    real_total += pair[1];
  }, {} );

  // create tag hashmap and assign percentage of real_total to each items
  var decorated = json.reduce( function( mod, pair ) {
    var tag = pair[0];
    var score = pair[1];
    var percent = (score*100) / real_total;
    mod[tag] = { tag: tag, score: score, percent: percent};
    return mod;
  }, {} );

  // fine tune each item percentage to make sure each item are not less
  // than 5% and reduce percentage of all other bigger items. repeat
  // until we are within [99%..101%] 
  var min_percent = 4;
  var new_total = 0;
  var small_count = 0;
  do {
    new_total = 0;
    small_count = 0;

    Object.keys( decorated ).forEach( function ( key ) {
      var item = decorated[key];
      if (item.percent < min_percent) {
        small_count += 1;
        item.percent = min_percent;
      }
      new_total += item.percent;

      decorated[key] = item;
    });

    if (new_total > 100) {
      var big_count = 10 - small_count;
      var skew = (new_total - 100) / big_count

      new_total = 0
      Object.keys( decorated ).forEach( function ( key ) {
        var item = decorated[key];
        if (item.percent >= min_percent + skew) {
          item.percent -= skew;
        }
        new_total += item.percent;
        decorated[key] = item;
      });
    }
  } while (Math.round(new_total) < 99 || Math.round(new_total) > 101);

  // to avoid %->px rounding errors, round all percents
  // and make sure total is exactly 100 by padding the first element
  // which should be the biggest (unless they are all equals) 
  new_total = 0
  Object.keys( decorated ).forEach( function ( key ) {
    var item = decorated[key];
    item.percent = Math.round(item.percent);
    new_total += item.percent;
    decorated[key] = item;
  });
  var first_key = Object.keys(decorated)[0];
  var item = decorated[first_key];
  item.percent = item.percent + (100 - new_total);
  decorated[first_key] = item;

  // finally set height and mapping on each items
  Object.keys( decorated ).forEach( function ( key ) {
    var item = decorated[key];
    item.height = item.percent;
    item.mapping = getMappingForString( key );
    decorated[key] = item;
  });

  return decorated;
};

var render = function( json ) {
  var tags = Object.keys( json );
  var $bar = $( '<div>').addClass('bar').appendTo('#viewer');
  tags.forEach( function(tag) {
    var data    = json[tag];
    var $cell    = $('<div>').addClass( 'cell ' + data.mapping.selector );
    var $helper  = $('<a>').attr({
      "class": "helper",
      "href" : 'https://twitter.com/#!/search/realtime/' + encodeURIComponent(tag),
      "title": tag
    }).text( tag )
    var $counter = $('<div>').addClass('counter').text( data.score );
    $cell.data(data).css('height', data.height+'%' );
    $cell.append(   $counter );
    $cell.append(   $helper  );
    $cell.appendTo( $bar     );
  });
};

var cleanup = function(argument) {
  var bars = $('.bar')
  if( bars.length > 5 ){
    var n = bars.length-5
    $('.bar:lt('+n+')').remove()
  };
};

var poll = function() {
  if( pollstate === 0){
    pollstate = 1
    var fetch = $.getJSON( 'rankings.json' );
    fetch.fail( function( error ){
      throw "Could not fetch rankings";
    });
    fetch.done( function( json) {
      if( json ){
        var decorated = decorate( json )
        render( decorated );
        cleanup()        
      }
    });    
    fetch.always( function() {
      pollstate = 0
      setTimeout( poll, polldelay );
    });
  }else{
    setTimeout( poll, polldelay );
  };
};

$(function() { poll() });
$('#reset-colors').on( 'click', function() { mappedColors = {}; });

