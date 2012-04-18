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
  var total = 0
  var decorated = json.reduce( function( mod, pair ) {
    var tag = pair[0];
    var score = pair[1];
    total += score;
    mod[tag] = { tag: tag, score: score };
    return mod;
  }, {} );
  
  Object.keys( decorated ).forEach( function ( key ) {
    var item = decorated[key];
    item.height = Math.round( (item.score*100)/total)+'%';
    item.mapping = getMappingForString( key )
    decorated[key] = item;
  });
  return decorated;
};

var render = function( json ) {
  var tags = Object.keys( json )
  var $bar = $( '<div>').addClass('bar').appendTo('#viewer')
  tags.forEach( function(tag) {
    var data    = json[tag];
    var $cell   = $('<div>').addClass('cell').addClass( data.mapping.selector );
    var $helper = $('<div>').addClass('helper').text( tag + ' ' + '(' + data.score + ')' );
    $cell.data(data).css('height', data.height );
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
  }
};

$(function() { poll() });

