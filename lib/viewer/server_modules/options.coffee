# Defaults
port         = 80
host         = "127.0.0.1"
redis_host   = "127.0.0.1"
redis_port   = 6379
mock = false
# parse args
exports.parse = ( argv )->
  argv.forEach (val, index, params) ->
    port = parseFloat(params[index + 1])  if /\-\-port|\-p$/.test(val)
    host = String(params[index + 1]).trim()  if /\-\-host$|\-h/.test(val)
    redis_port = parseFloat(params[index + 1])  if /\-\-redis-port|\-P$/.test(val)
    redis_host = String(params[index + 1]).trim()  if /\-\-redis-host|\-H/.test(val)
    mock = true if /\-\-mock|\-m/.test(val) 
  return port: port, host: host, redis_port: redis_port, redis_host: redis_host, mock: mock