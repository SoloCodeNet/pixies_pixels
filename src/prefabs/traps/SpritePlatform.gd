tool
extends Node2D

export (float) var IDLE_DURATION = 0.5
export (Vector2) var MOVE_TO = Vector2.RIGHT * 128
export (float) var SPEED = 1.0
export (Vector2) var spr_size = Vector2(4, 1) setget set_spr_size
export (bool) var movement : bool = false setget set_movement

var old_pos :Vector2
var new_pos :Vector2
var onn = false


func _ready():
	old_pos = Vector2.ZERO

func _process(delta: float) -> void:
	pass
	
func move_test():
	if onn == true: return
	onn = true
	var duration = MOVE_TO.length() / float(SPEED * 128)
	$Tween.interpolate_property($platform, "position", Vector2.ZERO, MOVE_TO, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, IDLE_DURATION)
	$Tween.interpolate_property($platform, "position", MOVE_TO, Vector2.ZERO, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, duration + IDLE_DURATION * 2)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	movement = false
	onn = false
	
func set_spr_size(value):
	spr_size = value
	test()
	
func test():
	if self.is_inside_tree():
		$platform/nine.rect_size=Vector2(8.0 * spr_size.x, 8.0 * spr_size.y)
		var p : PoolVector2Array = [
			Vector2(0, 0),
			Vector2(8 * spr_size.x, 0),
			Vector2(8 * spr_size.x, 8 * spr_size.y),
			Vector2(0, 8 * spr_size.y)
		]
		$platform/coll.polygon = p

	
func get_spr_size()-> Vector2:
	return spr_size
	
func set_movement(value)-> void:
	movement = value
	if !movement:
		$platform.position = Vector2.ZERO
	else:
		move_test()
	
	

