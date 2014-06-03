
TAU = Math.PI * 2 # pi sucks

AREA_SIZE = 10
TILE_SIZE = 32
MAX_ENTITY_SIZE = 128

at = (world_x, world_y)-> "#{~~world_x}, #{~~world_y}"

exp = {TAU, AREA_SIZE, TILE_SIZE, at, PORT, IP}

if module?
	
	PORT = process.env.OPENSHIFT_NODEJS_PORT ? 8080
	IP = process.env.OPENSHIFT_NODEJS_IP ? '127.0.0.1'

	express = require 'express'
	http = require 'http'
	socketio = require 'socket.io'
	
	app = express()
	server = app.listen(PORT, IP)
	console.log "Server listening on port :#{PORT}"
	
	exp.io = socketio.listen(server, {'log level': 2})
	
	app.use express.static(__dirname)
	
else
	window.socket = window.io.connect(location.origin)

for key, val of exp
	(module?.exports ? window)[key] = val
