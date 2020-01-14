extends KinematicBody2D
var vel: = Vector2.ZERO
	
func _physics_process(delta: float) -> void:
	vel.y += 2
	move_and_slide(vel)
	if get_slide_count() > 0: queue_free()
