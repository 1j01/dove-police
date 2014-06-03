

class @Entity
	# habs de id
	name: "Entity"
	constructor: (@EID)->
	
	update: ->
		# nop
	
	draw: (ctx)->
		throw new Error "trying to draw an entity that isn't drawable"
	
	toJSON: ->
		throw new Error "not implemented"

class @PhysicalEntity
	# habs de position
	# habs de physixz
	name: "Entity"
	constructor: (@EID)->
		@x = 0
		@y = 0
		@vx = 0
		@vy = 0
		@rotation = 0
	
	update: ->
		# physics here...
	
	draw: (ctx)->
		# draw a stupid placeholder shape
		ctx.fillStyle = '#a0a'
		ctx.fillRect -15, -10, 30, 20
		ctx.fillStyle = '#707'
		ctx.fillRect -5, -16, 10, 30
		ctx.fillStyle = '#505'
		ctx.fillRect -2, -2, 4, 4
	
	toJSON: ->
		{@x, @y, @vx, @vy, @rotation, _: @name}

class @Animal extends @PhysicalEntity
	# in case there are lions later in the game

class @Human extends @Animal
	# habs de arms, de shooting
	constructor: ({controls})->
		super()
		shirt_hue = Math.random()*360
		shirt_sat = Math.random()*100
		shirt_lit = Math.random()*100
		@shirt_color = "hsl(#{shirt_hue}, #{shirt_sat}%, #{shirt_lit}%)"
		@shirt_color_dark = "hsl(#{shirt_hue}, #{shirt_sat/2}%, #{shirt_lit/2}%)"
		
		@pants_color =
			if Math.random() < 0.4
				"hsl(#{
					Math.random()*360
				}, #{
					if Math.random()<0.1 then 70 else 40
				}%, #{
					if Math.random()<0.1 then 70 else 40
				}%)"
			else if Math.random() < 0.4
				"hsl(#{
					Math.random()*360
				}, #{
					if Math.random()<0.1 then 70 else 40
				}%, #{
					if Math.random()<0.1 then 70 else 40
				}%)"
			else
				"hsl(#{
					Math.random()*360
				}, #{
					if Math.random()<0.1 then 70 else 40
				}%, #{
					if Math.random()<0.1 then 70 else 40
				}%)"
		
		@look_x = 0
		@look_y = 0
		
	draw: (ctx)->
		# draw a stupid shape
		super(ctx)
		ctx.fillStyle = @shirt_color
		ctx.save()
		ctx.scale(2, 1)
		for i in [0..10]
			ctx.scale(0.1+i/5, 0.2+i/5)
			ctx.beginPath()
			ctx.arc(0, 0, 5, 0, TAU)
			ctx.fill()
		ctx.restore()
	
	update: ->
		if @controls
			@look_x = (@look_x + @controls.look_x) / 2
			@look_y = (@look_y + @controls.look_y) / 2
			@rotation = Math.atan2(@look_y, @look_x)
			
			@vx += @controls.move_x * 2
			@vy += @controls.move_y * 2
		
		@x += @vx
		@y += @vy
		@vx *= 0.7
		@vy *= 0.7

class @NPC extends @Human
	# habs de ai

class @Shopster extends @NPC
	# habs de goods

class @Playster extends @Human
	constructor: ({@controls, @view})->
		super({@controls})

class @Item extends @PhysicalEntity
	# in case there are collectable porcelain lions later in the game

class @Weapon extends @Item
	# lays da heat

module?.exports = {@Entity, @Animal, @Human, @NPC, @Shopster, @Playster}
