var pollstate  = 0;
var polldelay = 5000;

var vizData = [];
var vizDataMap = {};

var currentStreamgraphData = [];
var newStreamgraphData = [];

var width = 950;
var height = 600;
var mx = 19;
var my = 1500;

var area = d3.svg.area()
      .x(function(d) { return d.x * width / mx; })
      .y0(function(d) { return height - d.y0 * height / my; })
      .y1(function(d) { return height - (d.y + d.y0) * height / my; });

var vis = d3.select("#viewer")
  .append("svg")
  .attr("width", width)
  .attr("height", height);

var color = d3.interpolateRgb("#aad", "#556");

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

  newStreamgraphData = d3.layout.stack().offset("wiggle")(vizData);

  vis.selectAll("path")
    .data(newStreamgraphData)
    .enter().append("path")
    .style("fill", function() { return color(Math.random()); })
    .attr("d", area);
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