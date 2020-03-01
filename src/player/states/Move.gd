extends "res://src/global/Istate.gd"

var MAX_WALK_SPEED := 400.0
var MAX_RUN_SPEED := 1000.0
var ACCELLERATION_WALK := 3200.0
var ACCELLERATION_RUN := ACCELLERATION_WALK * 1.35
var AIR_FRICTION = 2000.0
var SLIDE_FACTOR = 1.2

func handled_states():
	return ["Walk", "Run"]
	
func pre_update():
	# détection des états
	if not owner.direction and owner.velocity.x == 0:
		return state("Idle")
	if Input.is_action_just_pressed("slide") and self.current_state == "Run" and not owner.glissade_recovery:
		return sub_state("Slide")
	if owner.request_jump:
		return state("Jump")
	if owner.velocity.y > 0 and not owner.is_on_ground_with_delay:
		return state("Fall")
	if Input.is_action_pressed("run") or abs(owner.velocity.x) > MAX_RUN_SPEED:
		return state("Run")
	state("Walk")

func update():
	
	# animation
	if Input.is_action_pressed("run"):
		self.animation_player.playback_speed = range_lerp (abs(owner.velocity.x), MAX_WALK_SPEED, MAX_RUN_SPEED, 0.5, 1)
		self.change_anim("run_", true)
	else:
		self.animation_player.playback_speed = range_lerp (abs(owner.velocity.x), 0.5, MAX_WALK_SPEED, 0.5, 1)
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
	self.animation_player.playback_speed = 1
