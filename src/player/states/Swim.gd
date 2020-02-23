extends "res://src/global/Istate.gd"

var swim_speed = 3000
var swim_max_speed = 200
var swim_jump = -600
export(float) var WATER_FRICTION := 1000

func enter(params = null, sub_state = false):
	Game.gravity_factor = 0.2

func update():
		
	if not owner._is_on_water():
		if owner.velocity.y < 0:
			return state("Jump")
		else:
			return state("previous")
	
	# déccélération
	owner.velocity.x = move_toward(owner.velocity.x, 0, WATER_FRICTION * self.delta)
	
	# mouvement	
	if owner.direction.x:
		owner.velocity.x += owner.direction.x * swim_speed * self.delta
	if abs(owner.velocity.x) > swim_max_speed :
		owner.velocity.x  = sign(owner.velocity.x) * swim_max_speed	

	# jump/limite
	if owner.request_jump:
		owner.velocity.y = swim_jump * Game.get_gravity_direction()
	else:
		owner.velocity.x = clamp(owner.velocity.x, -200, 200)
		owner.velocity.y = clamp(owner.velocity.y, -400, 150)

func exit(new_state):
	Game.gravity_factor = 1
