
TAU = Math.PI * 2 # pi sucks

AREA_SIZE = 10
TILE_SIZE = 32
MAX_ENTITY_SIZE = 128

at = (world_x, world_y)-> "#{~~world_x}, #{~~world_y}"

PORT = 3200

exp = {TAU, AREA_SIZE, TILE_SIZE, at, PORT}

if module?
	
	express = require 'express'
	http = require 'http'
	socketio = require 'socket.io'
	
	app = express()
	server = app.listen(PORT)
	console.log "Server listening on port :#{PORT}"
	
	exp.io = socketio.listen(server, {'log level': 2})
	
	app.use express.static(__dirname)
	
else
	window.socket = window.io.connect 'http://localhost'

for key, val of exp
	(module?.exports ? window)[key] = val
