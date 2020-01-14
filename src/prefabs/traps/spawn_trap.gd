extends Node2D


var boo: = false

func _ready() -> void:
	rewind()
	

func _on_anim_animation_finished(anim_name: String) -> void:
	boo = !boo
	rewind()

func rewind() -> void:
	$anim.play("alpha-up" if boo else "alpha-dw")
	
func spawn():
	print("x")
	var i = preload("res://src/prefabs/traps/projectile.tscn").instance()
	i.position = Vector2(0, 1)
	add_child(i)
	
	
