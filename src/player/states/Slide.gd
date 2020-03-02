extends "res://src/global/Istate.gd"

var exit := false
var SLIDE_DURATION := 0.6
var SLIDE_RECOVERY_DURATION := 0.5
var SLIDE_VELOCITY := 1400
onready var raycast_min_dist : RayCast2D =  $'../../StateNodes/MinSlideDistance'

func enter(params = null, sub_state = false):
	exit = false
	owner.velocity.x = SLIDE_VELOCITY * _get_glissade_direction()
	yield(get_tree().create_timer(SLIDE_DURATION),"timeout")
	exit = true

func pre_update():
	if owner.request_jump:
		state("Jump")

func update():	
	self.change_anim("slide_", true)
	if exit or owner.velocity.x == 0:
		return state("previous")

func exit(new_state):
	owner.glissade_recovery = true
	yield(get_tree().create_timer(SLIDE_RECOVERY_DURATION),"timeout")
	owner.glissade_recovery = false
	
func can_slide():
	if owner.glissade_recovery:
		return false
	raycast_min_dist.set_scale(Vector2(_get_glissade_direction(), 1))
	return !raycast_min_dist.is_colliding()

func _get_glissade_direction() -> int:
	if owner.direction.x != 0:
		return owner.direction.x
	if owner.velocity.x != 0:
		return 1 if owner.velocity.x > 0 else -1
	return 1
