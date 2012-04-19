port         = 80
host         = "127.0.0.1"
redis_host   = "127.0.0.1"
redis_port   = 6379
last_pop     = null
pop_interval = 1000
process.argv.forEach (val, index, params) ->
  port = parseFloat(params[index + 1])  if /\-\-port/.test(val)
  host = String(params[index + 1]).trim()  if /\-\-host/.test(val)
  redis_port = parseFloat(params[index + 1])  if /\-\-redis-port/.test(val)
  redis_host = String(params[index + 1]).trim()  if /\-\-redis-host/.test(val)

express = require("express")
redis = require("redis")
client = redis.createClient(redis_port, redis_host)
server = express.createServer()
server.configure ->
  server.use express.methodOverride()
  server.use express.bodyParser()
  server.use server.router

server.configure "development", ->
  server.use express["static"](__dirname + "/static")
  server.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

server.configure "production", ->
  server.use express["static"](__dirname + "/static",
    maxAge: oneYear
  )
  server.use express.errorHandler()

server.get "/rankings.json", (req, res, next) ->
  res.json last_pop

server.get "/stats.json", (req, res, next) ->
  res.json "{\"connections\":" + server.connections + "}"

poll = ()->
  client.lpop "rankings", (error, data) ->
    if error then return console.log error
    else if data then last_pop = data
    setTimeout poll, pop_interval

poll()

server.listen port, host
console.log "Started listening on " + host + ":" + port + " /w redis connection " + redis_host + ":" + redis_port
