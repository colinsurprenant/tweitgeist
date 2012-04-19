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

  var real_total = 0
  json.reduce( function( mod, pair ) {
    real_total += pair[1];
  }, {} );

  var decorated = json.reduce( function( mod, pair ) {
    var tag = pair[0];
    var score = pair[1];
    var percent = (score*100) / real_total;
    mod[tag] = { tag: tag, score: score, percent: percent};
    return mod;
  }, {} );

  var new_total = 0;
  var small_count = 0;

  do {
    new_total = 0;
    small_count = 0;

    Object.keys( decorated ).forEach( function ( key ) {
      var item = decorated[key];
      if (item.percent < 5) {
        small_count += 1;
        item.percent = 5;
      }
      new_total += item.percent;

      decorated[key] = item;
    });

    if new_total > 100 {
      var big_count = 10 - small_count;
      var skew = (100 - new_total) / big_count

      Object.keys( decorated ).forEach( function ( key ) {
        var item = decorated[key];
        if (item.percent >= 5 + skew) {
          item.percent -= skew;
        }
        item.mapping = getMappingForString( key );
        decorated[key] = item;
      });
    }
  } while (Math.round(new_total) != 100);


  // var total = 0
  // var decorated = json.reduce( function( mod, pair ) {
  //   var tag = pair[0];
  //   var score = pair[1];
  //   total     += score;
  //   mod[tag]  = { tag: tag, score: score };
  //   return mod;
  // }, {} );
  // var percentTotals = 0
  // Object.keys( decorated ).forEach( function ( key ) {
  //   var item = decorated[key];
  //   var percent = (item.score*100)/total;
  //   percentTotals+=percent;
  //   item.height = percent;
  //   item.mapping = getMappingForString( key )
  //   decorated[key] = item;
  // });

  return decorated;
};

var render = function( json ) {
  var tags = Object.keys( json )
  var $bar = $( '<div>').addClass('bar').appendTo('#viewer')
  tags.forEach( function(tag) {
    var data    = json[tag];
    var $cell   = $('<div>').addClass('cell').addClass( data.mapping.selector );
    var $helper = $('<div>').addClass('helper').text( tag + ' ' + '(' + data.score + ')' );
    $cell.data(data).css('height', data.height+'%' );
    $cell.append( $helper );
    $cell.appendTo( $bar );
  });
};

var cleanup = function function_name (argument) {
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
        var decorated = decorate( JSON.parse( json)  )
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

