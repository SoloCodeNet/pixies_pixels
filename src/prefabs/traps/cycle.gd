extends KinematicBody2D

var is_ok: = false

func _on_Timer_timeout() -> void:
	if is_ok:
		$Timer.wait_time = 2
		$coll.disabled = false
		$Sprite.modulate = Color(1,1,1,0)
	else:
		$Timer.wait_time = 1
		$coll.disabled = true
		$Sprite.modulate = Color(1,1,1,1)
	is_ok = ! is_ok
