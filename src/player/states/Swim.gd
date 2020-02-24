extends "res://src/global/Istate.gd"

var swim_speed = 3000
var swim_max_speed = 200
var swim_jump = -500
export(float) var WATER_FRICTION := 700

func enter(params = null, sub_state = false):
	Game.gravity_factor = 0.0

func update():
		
	if not owner._is_on_water():
		if owner.velocity.y < 0:
			return state("Jump")
		else:
			return state("previous")
	_change_anim()
	# déccélération
	owner.velocity.x = move_toward(owner.velocity.x, 0, WATER_FRICTION * self.delta)
	if owner.velocity.y > 25:
		owner.velocity.y = move_toward(owner.velocity.y, 25, WATER_FRICTION * self.delta * 0.5)
	# gravity
	if owner.velocity.y < 0:
		owner.velocity.y += 10
	else:
		owner.velocity.y += 0.1
	
	# mouvement	
	if owner.direction.x:
		owner.velocity.x += owner.direction.x * swim_speed * self.delta
	if owner.direction.y:
		owner.velocity.y += owner.direction.y * swim_speed * self.delta
	if abs(owner.velocity.x) > swim_max_speed :
		owner.velocity.x  = sign(owner.velocity.x) * swim_max_speed	

	# jump/limite
	if owner.request_jump:
		owner.velocity.y = swim_jump * Game.get_gravity_direction()
	else:
		owner.velocity.x = clamp(owner.velocity.x, -200, 200)
		owner.velocity.y = clamp(owner.velocity.y, -400, 200)

func exit(new_state):
	Game.gravity_factor = 1

func _change_anim():
	if owner.direction.x == 0:
		if owner.direction.y < 0:
			return self.animation_player.play("swim_U")
		elif owner.direction.y > 0:
			return self.animation_player.play("swim_D")
		else:
			return self.animation_player.play("swim_C")

	if owner.direction.x == 1:
		return self.animation_player.play("swim_R")
	else:
		return self.animation_player.play("swim_L")
