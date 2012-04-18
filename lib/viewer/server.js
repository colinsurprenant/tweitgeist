var client
  , express
  , redis
  , server
  , port = 80
  , host = '127.0.0.1'
  , redis_host = '127.0.0.1'
  , redis_port = 6379;

process.argv.forEach(function(val, index, params) {
   if( /\-\-port/.test( val )){
     port = parseFloat(params[index+1])
   };  
   if( /\-\-host/.test( val )){
     host = String( params[index+1] ).trim()
   };
   if( /\-\-redis-port/.test( val )){
     redis_port = parseFloat(params[index+1])
   };  
   if( /\-\-redis-host/.test( val )){
     redis_host = String( params[index+1] ).trim()
   };
});

express = require('express');
redis   = require('redis');
client  = redis.createClient( redis_port, redis_host );
server  = express.createServer();


server.configure(function() {
  server.use(express.methodOverride());
  server.use(express.bodyParser());
  return server.use(server.router);
});

server.configure('development', function() {
  server.use(express['static'](__dirname + '/static'));
  return server.use(express.errorHandler({
    dumpExceptions: true,
    showStack: true
  }));
});

server.configure('production', function() {
  server.use(express['static'](__dirname + '/static', {
    maxAge: oneYear
  }));
  return server.use(express.errorHandler());
});


server.get('/rankings.json', function(req, res, next) {
  client.lpop( 'rankings', function(error, data) {
    if (error) {
      return next(error);
    }
    return res.json(data);
  });
});

server.listen(port, host);
console.log( "Started listening on "+host+":"+port+" /w redis connection "+redis_host+":"+redis_port )