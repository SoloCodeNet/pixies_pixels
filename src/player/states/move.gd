extends "res://src/global/istate.gd"

export(float) var MAX_WALK_SPEED := 720.0
export(float) var MAX_RUN_SPEED := 1040.0
export(float) var ACCELLERATION_WALK := 3200.0
export(float) var ACCELLERATION_RUN := ACCELLERATION_WALK * 1.35
export(float) var AIR_FRICTION = 2000.0
export(float) var SLIDE_FACTOR = 1.2

func handled_states():
	return ["Walk", "Run"]
	
func pre_update():
	# détection des états
	if not owner.direction and owner.velocity.x == 0:
		return state("Idle")
	if owner.request_jump:
		return state("Jump")
	if owner.velocity.y > 0 and not owner.is_on_ground_with_delay:
		return state("Fall")
	state("Run") if Input.is_action_pressed("run") else state("Walk")

func update():
	
	# animation
	self.animation_player.playback_speed	 = range_lerp (abs(owner.velocity.x), 0.0, MAX_RUN_SPEED, 0, 2.5 )
	
	self.change_anim("walk_", true)
	
	var speed = ACCELLERATION_RUN if Input.is_action_pressed("run") else ACCELLERATION_WALK
	var max_speed = MAX_RUN_SPEED if Input.is_action_pressed("run") else MAX_WALK_SPEED
	
	# déccélération
	owner.velocity.x = move_toward(owner.velocity.x, 0, AIR_FRICTION * self.delta)
	
	# mouvement	
	if owner.direction.x:
		# application d'un facteur slide si changement de direction en mouvement
		if owner.velocity.x and not sign(owner.velocity.x) == sign(owner.direction.x):
			owner.velocity.x += owner.direction.x * speed * self.delta * SLIDE_FACTOR
		elif abs(owner.velocity.x) < max_speed:
			owner.velocity.x += owner.direction.x * speed * self.delta

	if abs(owner.velocity.x) > max_speed :
		owner.velocity.x  = lerp(owner.velocity.x , sign(owner.velocity.x) * max_speed, 0.1)	

func exit(new_state):
	self.animation_player.playback_speed	 = 1
