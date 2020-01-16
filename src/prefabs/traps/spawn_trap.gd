extends Node2D
signal kill()

var boo: = false

func _ready() -> void:
	yield(get_tree().create_timer(rand_range(0,2)),"timeout")
	rewind()
	

func _on_anim_animation_finished(anim_name: String) -> void:
	boo = !boo
	rewind()

func rewind() -> void:
	yield(get_tree().create_timer(rand_range(0,2)),"timeout")
	$anim.play("alpha-up" if boo else "alpha-dw")
	
func spawn():
	var i = preload("res://src/prefabs/traps/projectile.tscn").instance()
	i.position = Vector2(0, 1)
	add_child(i)
	

	
	
