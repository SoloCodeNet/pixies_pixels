extends "res://src/global/Istate.gd"

var exit := false
var glissade_duration := 0.8
var glissade_recovery_duration := 0.5
var glissade_vel := 1400

func enter(params = null, sub_state = false):
	exit = false
	self.change_anim("fall_C")
	owner.velocity.x = glissade_vel * _get_glissade_direction()
	yield(get_tree().create_timer(glissade_duration),"timeout")
	exit = true

func pre_update():
	if owner.request_jump:
		state("Jump")

func update():	
	if exit:
		return state("previous")


func exit(new_state):
	owner.glissade_recovery = true
	yield(get_tree().create_timer(glissade_recovery_duration),"timeout")
	owner.glissade_recovery = false

func _get_glissade_direction() -> int:
	if owner.direction.x != 0:
		return owner.direction.x
	if owner.velocity.x != 0:
		return 1 if owner.velocity.x > 0 else -1
	return 1
