extends "res://src/global/Istate.gd"

var DASH_DURATION := 0.4
var DASH_VEL_X = 1500

func enter(params = null, sub_state = false):
	owner.velocity.x = _get_dash_direction() * DASH_VEL_X
	owner.velocity.y = 0
	owner.cap_gravity = -1
	self.change_anim("dash_", true, false)
	yield(get_tree().create_timer(DASH_DURATION),"timeout")
	owner.cap_gravity = 0
	return sub_state("Jump", {}) if owner.velocity.y < 0 else sub_state("Fall")

func _get_dash_direction() -> int:
	if owner.direction.x != 0:
		return owner.direction.x
	return 1 if owner.velocity.x > 0 else -1


