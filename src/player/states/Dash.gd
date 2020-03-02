extends "res://src/global/Istate.gd"

var DASH_DURATION := 0.4
var DASH_VEL_X := 1500

var can_dash := true
onready var dash_min_heigth: RayCast2D = $'../../StateNodes/MinGroundDistance'

func enter(params = null, sub_state = false):
	can_dash = false
	owner.velocity.x = _get_dash_direction() * DASH_VEL_X
	owner.velocity.y = 0
	owner.apply_gravity = false
	self.change_anim("dash_", true, false)
	yield(get_tree().create_timer(DASH_DURATION),"timeout")
	owner.apply_gravity = true
	return sub_state("Jump", {}) if owner.velocity.y < 0 else sub_state("Fall")

func is_request_dash() -> bool:
	return Input.is_action_just_pressed('dash') and can_dash and owner.velocity.x != 0 and !dash_min_heigth.is_colliding()

func _get_dash_direction() -> int:
	if owner.direction.x != 0:
		return owner.direction.x
	return 1 if owner.velocity.x > 0 else -1

