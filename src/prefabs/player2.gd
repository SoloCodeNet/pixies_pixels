extends KinematicBody2D

onready var ray_up    = $raycasts/ray_up
onready var ray_dw    = $raycasts/ray_dw
onready var ray_floor = $raycasts/ray_floor

export(int) var jump_force = 200
export(int) var max_speed: = 300
export(float) var friction: = 0.1
export(float) var accel: = 0.05
export(int) var jump_max: = 2
export(int) var normal_gravity: = 10
export(float) var dash_time = 0.5

var str_state:String
var gravity: int
var jumping:bool
var climbing:bool
var dashing:bool
var running: bool

var speed: float = 0.0
var last_dir: int
var dir: = Vector2.ZERO
var vel:Vector2 = Vector2.ZERO
var jump_count:int=0
enum {IDLE, WALK, RUN, JUMP, WALL_JUMP, BOOST, CLIMB, WALL_SLIDE, DEAD}
var state

func _ready() -> void:
	last_dir = 1
	set_state(IDLE)

func _physics_process(delta: float) -> void:
	get_input(delta)
	set_anim()
	loop_state(delta)

	vel = move_and_slide(vel, Vector2.UP)
	$Label.text = str_state
	print(str_state)

	
func loop_state(delta: float) -> void:
	if not is_on_floor() and not climbing: vel.y +=normal_gravity 
		
	if is_on_floor() and jump_count!= 0:jump_count=0
	if dir.x!=0:
		set_state(WALK)
	else:
		set_state(IDLE)
		
	if jumping and not is_wall() and jump_count<jump_max:
		set_state(JUMP)
	if jumping and is_wall() and jump_count< jump_max:
		set_state(WALL_JUMP)
		
	if is_wall() and climbing :
		set_state(CLIMB)

	elif is_wall() and not climbing and vel.y > 0:

		set_state(WALL_SLIDE)
	else:
		set_state(IDLE)
	
func set_state(state_passed):
	match state_passed:
		IDLE:
			vel.x = lerp(vel.x,0,friction)
			str_state = "IDLE"
		WALK:
			vel.x = lerp(vel.x, dir.x * max_speed, accel)
			str_state = "WALK"
		JUMP: 
			vel.y +=normal_gravity 
			vel.y= -jump_force
			jump_count+=1
			str_state = "JUMP"

		WALL_JUMP:
			vel = Vector2(last_dir * -1 * jump_force, - jump_force)
			str_state = "WALL_JUMP"
			pass
		BOOST:
			pass
		CLIMB:
			vel.y = lerp(vel.y, 0, 0.5)
			str_state = "CLIMB"
		WALL_SLIDE:
			vel.y = normal_gravity * 3
			str_state = "WALL_SLIDE"
		DEAD:
			str_state = "DEAD"
			pass
			
	state = state_passed
	
func get_input(delta: float):
	dir = Vector2(
		Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	jumping = Input.is_action_just_pressed("ui_accept")
	dashing = Input.is_action_just_pressed("boost")
	running = Input.is_action_pressed("run")
	climbing = Input.is_action_pressed("climb") and is_wall()
	if not climbing and dir.x != 0:
		last_dir = dir.x
		ray_up.cast_to.x = 7 * last_dir
		ray_dw.cast_to.x = 7 * last_dir
	
	
func is_wall() -> bool:
	return ray_dw.is_colliding() and ray_up.is_colliding() and not ray_floor.is_colliding()
	
func set_anim():
	if dir.x > 0:$Sprite.flip_h=false
	if dir.x < 0:$Sprite.flip_h=true
