
{io, PORT, at, AREA_SIZE, TILE_SIZE} = require './client-server'
{Entity, Animal, Human, NPC, Shopster, Playster} = require './entities'

entities = {
	# [EID]: Entity
}
areas = {
	# [at wx, wy]: Area
}

EID_COUNTER = 0 # Entity ID

generate_area = (wx, wy)->
	for x in [0...AREA_SIZE]
		for y in [0...AREA_SIZE]
			"hsl(#{
				Math.random()*36+30
			}, #{
				if Math.random()<0.1 then 70 else 40
			}%, #{
				if Math.random()<0.1 then 70 else 40
			}%)"

for wx in [-5..5]
	for wy in [-5..5]
		areas[at wx, wy] = generate_area(wx, wy)

io.on 'connection', (socket)->
	
	my_entities = {
		# [EID]: Entity (Playster)
	}
	
	socket.on 'disconnect', ->
		for _eid of my_entities
			console.log 'removing', _eid, entities[_eid]
			delete entities[_eid]
	
	socket.on 'request area', ([wx, wy])->
		areas[at wx, wy] ?= generate_area(wx, wy)
		socket.emit 'area', {wx, wy, tiles: areas[at wx, wy]}
	
	socket.on 'request spawn', ({PID, x, y})->
		EID = EID_COUNTER++ # Entity ID
		
		playster = new Playster {PID, EID}
		my_entities[EID] = entities[EID] = playster
		
		playster.x = x ? 60
		playster.y = y ? 60
		
		socket.emit 'spawn',
			x: playster.x
			y: playster.y
			PID: PID # Player ID: This is so the client can keep track of which player is spawning.
			EID: EID
	
	socket.on 'update', (o)->
		if my_entities[o.EID]
			for key, val of o
				entities[o.EID][key] = val
		else
			socket.emit 'error', 'Try hacking in *any other way*'

	socket.on 'shoot', ({from})->
		
		# do bullet physics here
		to =
			x: from.x + Math.cos(from.rotation) * 1500
			y: from.y + Math.sin(from.rotation) * 1500
		
		# don't shoot from the center of the player
		from =
			x: from.x + Math.cos(from.rotation) * 20
			y: from.y + Math.sin(from.rotation) * 20
		
		io.sockets.emit 'shot', {from, to}

setInterval ->
	io.sockets.volatile.emit 'entities', entities
, 5
