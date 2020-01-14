extends KinematicBody2D

var touched := false
var vel: = Vector2.ZERO

func _process(delta: float) -> void:
	if touched: 
		vel.y += 2
	move_and_slide(vel)

func _on_Area2D_body_entered(body: Node) -> void:
	print(body.name)
	if !touched:
		$anim.play("touch")
		yield(get_tree().create_timer(0.5), "timeout")
		touched = true
	else:
		queue_free()
