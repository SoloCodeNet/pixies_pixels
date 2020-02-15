extends KinematicBody2D
var rot
var speed: float = 500.0
var default_mass:float = 40
var vel:= Vector2.ZERO
var start_pos := Vector2.ZERO

func start(pos:Vector2, rotation_angle :float, speed_bullet: float = 1000):
	rot = rotation_angle
	speed = speed_bullet
	rotation = rot
	start_pos = pos
	global_position = pos
	
func _ready() -> void:
	yield(get_tree().create_timer(0.01), "timeout")
	$Sprite.frame=3

func _process(delta: float) -> void:
	if global_position.distance_to(start_pos) > 10 and get_parent().has_node("player") :
		var p = get_parent().get_node("player")
		var follow = follow(vel,self.global_position, p.global_position, speed)
		vel += follow
	else:
		vel = Vector2(speed, 0).rotated(rot) 
	
	vel = move_and_slide(vel)
	if get_slide_count() > 0:
		queue_free()

func follow(
	velocity: Vector2,
	global_pos: Vector2,
	target_pos: Vector2,
	max_speed : float,
	mass: float = default_mass
	)-> Vector2:
		var desir: = (target_pos -global_pos).normalized() * max_speed
		var steer:= (desir - velocity) / mass
		return steer
