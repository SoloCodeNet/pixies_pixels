extends KinematicBody2D
var rot
var speed: float 
var default_mass:float = 50
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
	yield(get_tree().create_timer(0.01), "timeout")
	$Sprite.frame=3

func _process(delta: float) -> void:
	if global_position.distance_to(start_pos) > 10 and player :
		var player = get_parent().get_node("player")
		var follow = follow(vel,self.global_position, player.global_position, speed) 
		vel += follow * delta * 120
	
	vel = move_and_slide(vel)
	if get_slide_count() > 0:
		dead = true
		queue_free()

func follow(
	velocity: Vector2,
	global_pos: Vector2,
	target_pos: Vector2,
	max_speed : float,
	mass: float = default_mass
	)-> Vector2:
		var desir: = (target_pos -global_pos).normalized() * max_speed
		var steer:= (desir - velocity)  / mass
		return steer
