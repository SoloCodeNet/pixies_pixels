extends KinematicBody2D
var rot
var speed: float 
var mass:float = 50
var vel:= Vector2.ZERO
var start_pos := Vector2.ZERO
var dead = false
var player

func start(pos:Vector2, rotation_angle :float, speed_bullet: float = 1000, lifetime := 3):
	rot = rotation_angle
	speed = speed_bullet
	rotation = rot
	start_pos = pos
	global_position = pos
	vel = Vector2(speed, 0).rotated(rot) 
	player = get_parent().has_node("player") 
	if lifetime != 0:
		yield(get_tree().create_timer(lifetime),"timeout")
		if not dead:
			queue_free()
	
func _ready() -> void:
	$Sprite.frame=3

func _process(delta: float) -> void:
	if global_position.distance_to(start_pos) > 10 and player :
		var player = get_parent().get_node("player")
		var follow = Steering.follow(vel,self.global_position, player.global_position, speed, mass) 
		vel += follow * delta * 120
	
	vel = move_and_slide(vel)
	if get_slide_count() > 0:
		dead = true
		queue_free()
