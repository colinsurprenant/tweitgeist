var client, express, host, last_pop, poll, pop_interval, port, redis, redis_host, redis_port, server;
port = 80;
host = "127.0.0.1";
redis_host = "127.0.0.1";
redis_port = 6379;
last_pop = null;
pop_interval = 1000;
process.argv.forEach(function(val, index, params) {
  if (/\-\-port/.test(val)) {
    port = parseFloat(params[index + 1]);
  }
  if (/\-\-host/.test(val)) {
    host = String(params[index + 1]).trim();
  }
  if (/\-\-redis-port/.test(val)) {
    redis_port = parseFloat(params[index + 1]);
  }
  if (/\-\-redis-host/.test(val)) {
    return redis_host = String(params[index + 1]).trim();
  }
});
express = require("express");
redis = require("redis");
client = redis.createClient(redis_port, redis_host);
server = express.createServer();
server.configure(function() {
  server.use(express.methodOverride());
  server.use(express.bodyParser());
  return server.use(server.router);
});
server.configure("development", function() {
  server.use(express["static"](__dirname + "/static"));
  return server.use(express.errorHandler({
    dumpExceptions: true,
    showStack: true
  }));
});
server.configure("production", function() {
  server.use(express["static"](__dirname + "/static", {
    maxAge: oneYear
  }));
  return server.use(express.errorHandler());
});
server.get("/rankings.json", function(req, res, next) {
  return res.json(last_pop);
});
poll = function() {
  return client.lpop("rankings", function(error, data) {
    if (error) {
      return console.log(error);
    } else if (data) {
      last_pop = data;
    }
    return setTimeout(poll, pop_interval);
  });
};
poll();
server.listen(port, host);
console.log("Started listening on " + host + ":" + port + " /w redis connection " + redis_host + ":" + redis_port);