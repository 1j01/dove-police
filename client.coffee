
canvas = document.createElement 'canvas'
document.body.appendChild canvas
ctx = canvas.getContext '2d'

do window.onresize = ->
	canvas.width = document.body.clientWidth
	canvas.height = document.body.clientHeight

window.oncontextmenu = -> no

socket.on '', ->

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
	
	
