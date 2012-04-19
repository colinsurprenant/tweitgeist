var pollstate  = 0;
var polldelay = 5000;

var decorate = function( json ) {
  var total = 0
  var decorated = json.reduce( function( mod, pair ) {
    var tag = pair[0];
    var score = pair[1];
    total     += score;
    mod[tag]  = { tag: tag, score: score };
    return mod;
  }, {} );
  var percentTotals = 0
  Object.keys( decorated ).forEach( function ( key ) {
    var item = decorated[key];
    var percent = (item.score*100)/total;
    percentTotals+=percent;
    item.height = percent;
    decorated[key] = item;
  });
  return decorated;
};

var render = function( json ) {
  console.log(json);
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