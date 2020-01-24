extends Node2D
class_name laser_base

export (Color) var lazer_color = Color.red
export (int) var lazer_length = 200
export (bool) var emitting := true setget set_emiting
export (int) var revolution := 0 
export (int) var move_time := 5
export (bool) var revert_rotate:=false
export (Vector2) var end_point = Vector2.ZERO
export (int) var on_time = 0
export (int) var off_time = 0
var action: = false
var action2:= false
var rewind: = false
var one_point: = Vector2.ZERO
var revert_rota:= 1
var revert_switch:= false
var longueur:=0.0

func set_emiting(value):
	emitting = value
	lazer_switch(emitting)
	$tm_switch.start()
	
func _ready() -> void:
	$tm_switch.wait_time = on_time
	revert_rota = -1 if revert_rotate else 1
	one_point = self.global_position
	$line.color = lazer_color
	$blur.color = Color(lazer_color.r, lazer_color.g, lazer_color.b, 0.5)
	$tm_bright.start()
	if on_time != 0 and off_time != 0: $tm_switch.start() # active le clignotement

func _process(delta: float) -> void:
	if revolution != 0 : lazer_rotation() # active la rotation en donnant un temps de revolution
	if end_point != Vector2.ZERO: lazer_move() # active le deplacement 
	$ray.cast_to = Vector2(lazer_length, 0)

	if $ray.is_colliding():
		longueur =  $ray.global_position.distance_to($ray.get_collision_point())
		var obj = $ray.get_collider()
		if obj != null and  obj.name == "player":
			obj.call_deferred("emit_signal", "dead")
			
	$particle.emitting = $ray.is_colliding()
	$particle.position.x = 4 + longueur 
	$blur.rect_size.x = longueur
	$line.rect_size.x = longueur

func _on_tm_bright_timeout() -> void:
	$tm_bright.wait_time = rand_range(0.1,0.3)
	$blur.color.a = rand_range(0.0,0.3)
	$tm_bright.start()
	
func lazer_rotation():
	if action: return 
	action = true
	var a = self.rotation_degrees
	$tw_rotate.interpolate_property(self, "rotation_degrees", a, a+ (360* revert_rota), revolution, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$tw_rotate.start()
	yield($tw_rotate, "tween_all_completed")
	action = false
	
func lazer_move():
	if action2: return 
	action2 = true
	var o = one_point + end_point
	var a = o if rewind else one_point
	var b = one_point if rewind else o
	$tw_move.interpolate_property(self, "global_position", a, b, move_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$tw_move.start()
	yield($tw_move, "tween_all_completed")
	rewind=!rewind 
	action2 = false
	
func lazer_switch(emit):
	longueur = lazer_length if emit else 0
	$ray.enabled = emit

func _on_tm_switch_timeout() -> void:
	if !emitting: return
	$tm_switch.wait_time = off_time if revert_switch else on_time
	revert_switch = !revert_switch
	lazer_switch(revert_switch)
	$tm_switch.start()
	
