extends KinematicBody2D

var is_ok: = false
var current:=false
var alpha := 1.0
func _process(delta: float) -> void:
	if is_ok:
		$Timer.wait_time = 2
		$coll.disabled = is_ok
		alpha = lerp(alpha, 0, 0.005)
		$Sprite.modulate = Color(1,1,1,alpha)
	else:
		$Timer.wait_time = 1
		$coll.disabled = is_ok
		alpha = lerp(alpha, 1, 0.005)
		$Sprite.modulate = Color(1,1,1,alpha)

func _on_Timer_timeout() -> void:
	is_ok = ! is_ok
