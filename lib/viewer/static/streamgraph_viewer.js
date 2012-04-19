var pollstate  = 0;
var polldelay = 5000;

var vizData = [];
var vizDataMap = {};

var decorate = function( json ) {
  var decorated = json.reduce( function( mod, pair ) {
    var tag = pair[0];
    var score = pair[1];
    mod[tag]  = { tag: tag, score: score };
    return mod;
  }, {} );

  return decorated;
};

var render = function( json ) {
  Object.keys( json ).forEach( function ( key ) {
    if (vizDataMap[key] == undefined) {
      vizDataMap[key] = vizData.length;
    }
    
    if (vizData[vizDataMap[key]] == undefined) {
      vizData[vizDataMap[key]] = [{x: 0, y: json[key]["score"]}];
    }
    else {
      if (vizData[vizDataMap[key]].length == 20) {
        vizData[vizDataMap[key]].shift();

        pos = 0;
        Object(vizData[vizDataMap[key]]).forEach(function(i) {
          i["x"] = pos;
          pos = pos + 1;
        });

        vizData[vizDataMap[key]].push({x: vizData[vizDataMap[key]].length, y: json[key]["score"]});
      }
      else {
        vizData[vizDataMap[key]].push({x: vizData[vizDataMap[key]].length, y: json[key]["score"]});
      }
    }
  });

  console.log(vizDataMap);
  console.log(vizData);
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