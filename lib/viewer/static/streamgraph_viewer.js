var pollstate  = 0;
var polldelay = 2500;

var vizData = [];
var vizDataMap = {};

var currentStreamgraphData = [];
var newStreamgraphData = [];

var width = 950;
var height = 600;
var mx = 199;
var my = 0;

var color = d3.interpolateRgb("#009fff", "#fff");
var colors = [];

var hashtags = [];

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
  Object(vizData).forEach( function (data){
    data.shift();

    Object(data).forEach(function(item, i) {
        item["x"] = i;
    });

    data.push({x: 199, y: 0});
  })

  Object.keys( json ).forEach( function ( key ) {
    if (typeof vizDataMap[key] == "undefined") {
      vizDataMap[key] = vizData.length;
      colors.push(color(Math.random()));
      hashtags.push(key);
    }
    
    if (typeof vizData[vizDataMap[key]] == "undefined") {
      vizData[vizDataMap[key]] = [];

      i = 0;
      for (i = 0; i <= (mx - 1); i = i+1) {
        vizData[vizDataMap[key]][i] = {x: i, y: 0};
      }

      vizData[vizDataMap[key]].push({x: 199, y: json[key]["score"]});
    }
    else {
      vizData[vizDataMap[key]][199] = {x: 199, y: json[key]["score"]};
    }
  });

  newStreamgraphData = d3.layout.stack().offset("wiggle")(vizData);

  my = d3.max(newStreamgraphData, function(d) {
         return d3.max(d, function(d) {
           return d.y0 + d.y;
         });
       });

  area = d3.svg.area()
    .x(function(d) { return d.x * width / mx; })
    .y0(function(d) { return height - d.y0 * height / my; })
    .y1(function(d) { return height - (d.y + d.y0) * height / my; });

  d3.select("#graph").remove();
    
  vis = d3.select("#viewer")
    .append("svg")
    .attr("width", width)
    .attr("height", height)
    .attr("id", "graph");

  vis.selectAll("path")
    .data(newStreamgraphData)
    .enter().append("path")
    .style("fill", function(item,i) {
      return colors[i];
    })
    .attr("d", area)
    .attr("class", "svg_tooltip")
    .attr("title", function(item,i) {
      return hashtags[i];
    });

  $('.svg_tooltip').hover(function () {
    $("#hashtag_anchor").html($(this).attr("title"));
  });
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
        var decorated = decorate( json  )
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