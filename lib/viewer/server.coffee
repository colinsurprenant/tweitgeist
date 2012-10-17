express = require 'express'
redis   = require 'redis'
fs      = require 'fs'
config  = require('./server_modules/options.coffee').parse(process.argv)
mock    = require './server_modules/mock.coffee'
client  = if config.mock then mock else redis.createClient(config.redis_port, config.redis_host)
info    = JSON.parse fs.readFileSync 'package.json'
server  = express.createServer()

# multi user fix™ 
last_pop     = null
last_rate    = 0
pop_interval = 1000

# all environments
server.configure ->
  server.use express.methodOverride()
  server.use express.bodyParser()
  server.use server.router

# development 
server.configure "development", ->
  server.use express["static"](__dirname + "/static")
  server.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )
  
# production
server.configure "production", ->
  server.use express["static"](__dirname + "/static",
    maxAge: oneYear
  )
  server.use express.errorHandler()

server.get "/rankings.json", (req, res, next) ->
  res.json last_pop

server.get "/stats.json", (req, res, next) ->
  res.json "{\"connections\":" + server.connections + ",\"stream_rate\":" + last_rate + "}"

poll_rankings = () ->
  client.lpop "rankings", (error, data) ->
    if error then return console.log error
    else if data
      last_pop = if typeof data is 'string' then JSON.parse(data) else data
    setTimeout poll_rankings, pop_interval

poll_rankings()

poll_stream_rate = ()->
  client.lpop "stream_rate", (error, data) ->
    if error then return console.log error
    else if data then last_rate = data
    setTimeout poll_stream_rate, 2000

poll_stream_rate()

server.listen config.port, config.host, ->
  console.log(
    "\ntweitgeist node server v#{info.version}\n" +
    "\nstarted listening on host #{config.host} port #{config.port}"
  )
  if config.mock
    console.log "using mock data"
  else
    console.log "using redis on host #{config.redis_host} port #{config.redis_port}"