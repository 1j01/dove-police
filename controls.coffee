
class @Controls
	constructor: ->
		@move_x = 0
		@move_y = 0
		
		@look_x = 0
		@look_y = 0
		
		@shoot = no

class @KeyboardMouseControls extends Controls
	constructor: ->
		super()
		
		@keys = {}
		@mouse_x_in_view = 0
		@mouse_y_in_view = 0
		
		window.addEventListener 'keydown', (e)=>
			@keys[e.keyCode] = yes
		
		window.addEventListener 'keyup', (e)=>
			delete @keys[e.keyCode]
		
		window.addEventListener 'mousemove', (e)=>
			if @playster
				@mouse_x_in_view = e.clientX # _in_view = @todo
				@mouse_y_in_view = e.clientY
			else
				console.log 'KeyboardMouseControls waiting for playster'
		
		window.addEventListener 'mousedown', (e)=>
			@shoot = yes
		
		window.addEventListener 'mouseup', (e)=>
			@shoot = no
	
	update: ->
		right = @keys[39]? or @keys[68]?
		left = @keys[37]? or @keys[65]?
		down = @keys[40]? or @keys[83]?
		up = @keys[38]? or @keys[87]?
		@move_x = right - left
		@move_y = down - up
		
		if @playster
			@look_x = @mouse_x_in_view - @playster.x #_in_view @todo
			@look_y = @mouse_y_in_view - @playster.y #_in_view

class @GamepadControls extends Controls
	constructor: (@gamepad)->
		super()
		console.log @gamepad
	
	update: ->
		precision = 0.09
		#axes = for a in @gamepad.axes
		#	if Math.abs(a) < precision then 0 else a
		
		axes = @gamepad.axes
		
		if @gamepad.mapping is "standard"
			# standard xinput controller
			
			@move_x = axes[0]
			@move_y = axes[1]
			
			@look_x = axes[2]
			@look_y = axes[3]
		else
			# standard xinput controller not detected (or properly mapped) on firefox
			
			@move_x = axes[0]
			@move_y = axes[1]
			# ....... axes[2] = (ltrigger - rtrigger)
			@look_x = axes[3]
			@look_y = axes[4]
		
		@shoot = @gamepad.buttons[0].pressed
		
		if Math.abs(@move_x) < precision and Math.abs(@move_y) < precision
			@move_x = 0
			@move_y = 0
		
		if Math.abs(@look_x) < precision and Math.abs(@look_y) < precision
			@look_x = 0
			@look_y = 0
		
		# look in the direction you're moving if you're not looking a different way
		look_amount = Math.sqrt(@look_x*@look_x + @look_y*@look_y)
		if look_amount < 0.2
			@look_x = @move_x
			@look_y = @move_y
	
