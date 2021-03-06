extends "res://src/global/Istate.gd"

func enter(params = null, sub_state = false):
	self.change_anim("idle_1")
	
func pre_update():
	if owner.request_jump:
		state("Jump")

func update():
	if owner.direction or owner.velocity:
		if Input.is_action_pressed("run"):
			return state("Run")
		else:
			return state("Walk")
