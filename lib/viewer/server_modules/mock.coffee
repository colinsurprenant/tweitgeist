semirandom = ( min, mod )-> Math.floor Math.random()*mod+min
exports.lpop = ( arg, callback )->
  # note: these numbers mean nothing and are completely arbitrary!
  trends = [
    [ "#ICEWEASELS", semirandom( 123, 50 ) ]
    [ "#ACE", semirandom( 98,  50 ) ]
    [ "#BELARUS", semirandom( 87,  50 ) ]   
    [ "#CHUMBUKIT", semirandom( 76,  50 ) ]      
    [ "#CANHAZ", semirandom( 65,  50 ) ]        
    [ "#YARR", semirandom( 54,  50 ) ]          
    [ "#YANILIVE", semirandom( 43,  50 ) ]            
    [ "#NONBELIEBER", semirandom( 32,  50 ) ]              
    [ "#YMMV", semirandom( 32,  50 ) ]              
    [ "#DEADBEEF", semirandom( 32,  50 ) ]              
  ]
  randoms    = [ "#THEDUDE", "#COWABUNGA", "#WOWSERS" , "#SHINJUKU" , "#NEEDIUM", "#MYFACE", "#BORING" ]
  onOccasion =  ( Math.floor( Math.random()*2 )%2 is 1 )
  if onOccasion
    randidx  = Math.floor Math.random()*randoms.length
    trendidx = Math.floor Math.random()*trends.length
    trends[ trendidx ][0] = randoms[randidx]
  callback( null, trends )
  return trends
