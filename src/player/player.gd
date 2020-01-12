extends KinematicBody2D
class_name Player

var velocity := Vector2.ZERO
var direction = Vector2.ZERO
var previous_direction = Vector2.ZERO
var state = null
var special_state = null
var debug_label: Label = null
var debug_label_text = null
var mass = 2
var cap_gravity = 0 # permets de capper le gravité lors du walljump
var can_move = true # permets d'annuler le move and slide
var request_jump = false setget , get_request_jump # permets d'avoir un saut avec une certaine tolérance
var is_on_ground_with_delay = true # donne un  délai pour autoriser un saut en retard
var is_on_ground_with_delay_waiting = false
var is_force_applied = false # true si le player subit une force

onready var state_machine  := $StateMachine
onready var special_state_machine  := $SpecialStateMachine

func _ready() -> void:
	name = "player"
	Engine.time_scale = Game.time_scale
	state_machine.init()
	special_state_machine.init("None", "special_state")

	if Game.debug:
		debug_label = Label.new()
		debug_label.align = debug_label.ALIGN_CENTER
		debug_label.add_font_override("font", load("res://resources/montserrat.tres"))
		self.add_child(debug_label)
		
func _physics_process(delta):

	if Game.debug:
		var body_size = $body.texture.get_size()
		if special_state.name != "None":
			debug_label.text = special_state.name + "\n"
		debug_label.text = state.name + "\n" + str(velocity.floor())
		if debug_label_text:
			debug_label.text += "\n" + str(debug_label_text)
#		debug_label.rect_position = Vector2(-(body_size.x * $body.scale.x)/2 - 25, - 100)
		debug_label.rect_position = Vector2(0, -200)
	if not is_on_floor() and can_move:
		velocity.y += Game.gravity * Game.gravity_factor * delta
		if cap_gravity != 0:
			velocity.y = clamp(velocity.y, -10, cap_gravity)
	else: velocity.y = 0
			
	previous_direction = direction
	direction = _get_direction()
	
	_update_is_on_ground_with_delay()
	_update_request_jump()

	# State Machine Flow
	state_machine.pre_update()
	special_state_machine.pre_update()
	state_machine.update()
	special_state_machine.update()
	if can_move:
		move()
	state_machine.post_update()
	special_state_machine.pre_update()

func move() -> Vector2:
	var snap: Vector2 = Game.floor_normal * -1 * 8.0 if direction.y == 0.0 and state.name != "Jump" else Vector2.ZERO
	
	# On évite les valeurs extrêmes (force)
	velocity.x = clamp(velocity.x, -200, 200)
	velocity.y = clamp(velocity.y, -100, 100)
	
	velocity = move_and_slide_with_snap(velocity, snap, Game.floor_normal, true)
	return velocity

func update_look_direction(force_direction = null) -> void:
	if force_direction:
		$body.flip_h =  force_direction < 0
	elif direction:
		$body.flip_h =  direction.x < 0
	else:
		$body.flip_h = velocity.x < 0

func set_dead(value: bool) -> void:
	set_process_input(not value)
	set_physics_process(not value)
	$CollisionShape2D.disabled = value

func apply_force(force: Vector2) -> void:
	self.velocity += force/self.mass
	
func get_request_jump() -> bool:
	if request_jump:
		request_jump = false
		return true
	return false
	
func _update_is_on_ground_with_delay() -> void:
	"""
		Permets un retard lors des sauts pour éviter de frustrer le joueur, pour ce faire,
		on va donné un petit délai avant de passer de l'état move à fall.
	"""
	if is_on_floor()	:
		self.is_on_ground_with_delay = true
	elif not is_on_floor() and not is_on_ground_with_delay_waiting:
		is_on_ground_with_delay_waiting = true
		yield(get_tree().create_timer(0.10),"timeout")
		is_on_ground_with_delay_waiting = false
		if not is_on_floor():
			self.is_on_ground_with_delay = false
func animator(anim:String):
	if $AnimationPlayer.current_animation != anim:
		$AnimationPlayer.play(anim)
	
func _update_request_jump() -> void:
	"""
		Permets d'avoir un temps petit temps de retard pour un saut, cela améliore fortement le gameplay
	"""
	if not request_jump and Input.is_action_just_pressed('jump'):
		request_jump = true
		yield(get_tree().create_timer(0.1),"timeout")
		request_jump = false

static func _get_direction() -> Vector2:
	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return direction