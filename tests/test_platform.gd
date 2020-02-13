tool
extends Node2D

export (bool) var test_bool = false setget set_test_bool
export (Vector2) var move_to = Vector2.ZERO
export (float) var time_to = 2
export (float) var wait = 0.3
var ok = false
var run = false

func _enter_tree() -> void:
	ok =  is_inside_tree()
	set_process(true)

func _ready() -> void:
	print("ready: ", ok)

func _process(delta: float) -> void:
	action()
	

func action() -> void:
	if run: return
	var end = move_to
	var t = time_to
	run = true
	$tw.interpolate_property($kb, "position", Vector2.ZERO, end, t, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$tw.interpolate_property($kb, "position", end, Vector2.ZERO, t, Tween.TRANS_LINEAR, Tween.EASE_IN, t + wait)
	$tw.start()
	yield($tw, "tween_all_completed")
	yield(get_tree().create_timer(wait), "timeout")
	run = false
	
func set_test_bool(value)-> void:
	test_bool = value
	set_process(test_bool)


	

