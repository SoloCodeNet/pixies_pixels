extends Node2D
export(float) var speed  :float    = 1000.0
export(float) var cooldown : float = 0.1
export(float) var timed : float    = 0.5
export(int)   var rattle : int     = 3
export(float) var rota_speed: float= 0.4
export(bool) var is_locked: float = false
onready var tm = $Timer
onready var pos = $head/pos

func _ready() -> void:
	tm.wait_time = timed
	

func _process(delta: float) -> void:
	if is_locked: return 
	if owner.has_node("player"):
		var player = owner.get_node("player")
		var pos = player.global_position
		if $head.get_angle_to(pos) > 0 :
			$head.rotation += deg2rad(rota_speed)
		else: 
			$head.rotation -= deg2rad(rota_speed)


func _on_Timer_timeout() -> void:
	for x in range(rattle):
		var b = preload("res://src/prefabs/machinegun/bullet.tscn").instance()
		get_parent().add_child(b)
		b.start(pos.global_position, $head.rotation, speed)
		yield(get_tree().create_timer(cooldown), "timeout")
		
