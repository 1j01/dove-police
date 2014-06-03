
areas = {
	# [at wx, wy]: Area
}
entities = {
	# [EID]: Entity
}
playsters = {
	# [PID]: Playster
}
my_entities = {
	# [EID]: Entity (Playster)
}
effects = []


class Effect
	constructor: ->
		@life = @starting_life = 20
		effects.push @
	
	update: ->
		if @life-- <= 0
			effects.splice(effects.indexOf(@), 1)

class GunShotEffect extends Effect
	constructor: ({@from, @to})->
		super()
		@life = @starting_life = 3
	
	draw: (view)->
		ctx.lineWidth = 1.4
		ctx.strokeStyle = "rgba(255, 255, 255, #{@life / @starting_life})"
		ctx.beginPath()
		ctx.moveTo(@from.x, @from.y)
		ctx.lineTo(@to.x, @to.y)
		ctx.stroke()


class Area
	constructor: (@wx, @wy)->
		@tiles =
			for x in [0...AREA_SIZE]
				for y in [0...AREA_SIZE]
					'#006'
	load: (@tiles)->
	draw: (view)->
		W = H = AREA_SIZE * TILE_SIZE
		X = @wx * W
		Y = @wy * H
		
		#/2 is 4  t 3 st 1 ng ... 0
		if X + W/2 > view.left and Y + H/2 > view.top and X - W/2 < view.right and Y - H/2 < view.bottom
			# todo: only draw intersection with view
			ctx.save()
			ctx.translate(@wx * W, @wy * H)
			for row, ax in @tiles
				for tile, ay in row
					ctx.fillStyle = tile
					ctx.fillRect(ax * TILE_SIZE, ay * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			ctx.restore()

socket.on 'area', ({wx, wy, tiles})->
	#console.log 'recieved area '+at wx, wy
	areas[at wx, wy]?.load(tiles)

load_area = (wx, wy)->
	if not areas[at wx, wy]
		areas[at wx, wy] = new Area(wx, wy)
		socket.emit 'request area', [wx, wy]

for wx in [-5..5]
	for wy in [-5..5]
		load_area(wx, wy)


canvas = document.createElement('canvas')
document.body.appendChild(canvas)
ctx = canvas.getContext('2d')

do window.onresize = ->
	canvas.width = document.body.clientWidth
	canvas.height = document.body.clientHeight

window.oncontextmenu = -> no

socket.on 'entities', (_entities)->
	for _eid, _e of _entities
		if not entities[_eid]
			console.log 'entity', _entities[_eid]
			#entities[_eid] = new Entitiy(_eid)
			entities[_eid] = new Playster({})
			entities[_eid].eid = _eid
		
		if not my_entities[_eid]
			for key, val of _e
				entities[_eid][key] = val
	
	for eid, e of entities
		if not _entities[eid]
			entities[eid].destroy?()
			delete entities[eid]

socket.on 'shot', ({from, to})->
	new GunShotEffect({from, to})


join = (controls)->
	joining_PID = 'PID'+(Math.random()*567567)
	
	socket.emit 'request spawn', {PID: joining_PID}
	console.log 'request spawn', {PID: joining_PID}
	
	socket.on 'spawn', ({PID, EID, x, y})->
		if PID is joining_PID
			p = new Playster({controls})
			
			p.x = x or 160
			p.y = y or 160
			p.EID = EID
			p.PID = PID
			
			entities[EID] = p
			playsters[PID] = p
			my_entities[EID] = p
			controls.playster = p
			
			console.log 'spawned', p

join new KeyboardMouseControls()

###
window.addEventListener 'gamepadconnected', (e)->
	join new GamepadControls(e.gamepad)

window.addEventListener 'gamepaddisconnected', (e)->
	console.log "Gamepad disconnected at index #{e.gamepad.index}: #{e.gamepad.id}."
###

good_old_gamepads = []

do animate = ->
	requestAnimationFrame animate
	#setTimeout animate, 30
	
	ctx.fillStyle = '#041'
	ctx.fillRect 0, 0, canvas.width, canvas.height
	
	view =
		left: 0
		top: 0
		width: canvas.width
		height: canvas.height
		right: canvas.width
		bottom: canvas.height
	
	for _pid, p of playsters
		p.controls.update()
		load_area(
			~~(p.x / TILE_SIZE / AREA_SIZE)
			~~(p.y / TILE_SIZE / AREA_SIZE)
		)
		socket.emit 'update', {EID: p.EID, x: p.x, y: p.y, vx: p.vx, vy: p.vy, rotation: p.rotation}
		if p.controls.shoot
			console.log 'shoot', from: {x: p.x, y: p.y, rotation: p.rotation}
			socket.emit 'shoot', from: {x: p.x, y: p.y, rotation: p.rotation}
	
	for _loc, area of areas
		area.draw(view)
	
	for _eid, e of entities
		e.update()
	
	for _eid, e of entities
		ctx.save()
		ctx.translate(e.x, e.y)
		ctx.rotate(e.rotation + TAU/4)
		e.draw(ctx)
		ctx.restore()
	
	for e in effects
		e.update()
		e.draw()
	
	new_gamepads = navigator.getGamepads?() or navigator.webkitGetGamepads?() or navigator.webkitGamepads or something?
	if new_gamepads
		for gamepad in new_gamepads when gamepad? and gamepad.buttons.length
			
			gamepad_is_new = yes
			for old_gamepad in good_old_gamepads
				if gamepad is old_gamepad
					gamepad_is_new = false
			
			if gamepad_is_new
				join new GamepadControls(gamepad)
		
		good_old_gamepads = new_gamepads
