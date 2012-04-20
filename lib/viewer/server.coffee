fs      = require 'fs'
config  = require( './server_modules/options.coffee' ).parse( process.argv )
mock    = require './server_modules/mock.coffee'
express = require 'express'
redis   = require 'redis'
client  = if config.mock then mock else redis.createClient( config.redis_port, config.redis_host )
server  = express.createServer()
info    = JSON.parse fs.readFileSync 'package.json'

# multi user fix™ 
last_pop     = null
pop_interval = 1000

# All environments
server.configure ->
  server.use express.methodOverride()
  server.use express.bodyParser()
  server.use server.router

# Development 
server.configure "development", ->
  server.use express["static"](__dirname + "/static")
  server.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )
  
# Production
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
    else if data
      last_pop = if typeof data is 'string' then JSON.parse( data ) else data
    setTimeout poll, pop_interval

poll()

server.listen config.port, config.host, ->
  console.log "
  \nTweitgeist node server v#{info.version}\n
  \nStarted listening on 
  \n host:#{config.host} 
  \n port:#{config.port}"
  if config.mock
    console.log "With mock data"
  else
    console.log "
    With Redis redis connection 
    \n host:#{config.redis_host} 
    \n port:#{config.redis_port}"
