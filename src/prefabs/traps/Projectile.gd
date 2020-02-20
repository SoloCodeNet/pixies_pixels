extends KinematicBody2D
var vel: = Vector2.ZERO

func _physics_process(delta: float) -> void:
	vel.y += 4
	move_and_slide(vel)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("player"):
			collision.collider.emit_signal("dead")

	if get_slide_count()> 0: queue_free()

