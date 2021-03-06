extends KinematicBody2D
class_name Player
signal dead()

var str_direction:String=""
var velocity := Vector2.ZERO
var direction := Vector2.ZERO
var previous_direction := Vector2.ZERO
var state = null
var special_state = null
var debug_label: Label = null
var debug_label_text = null
var mass := 2
var cap_gravity := 0.0 # permets de capper le gravité lors du walljump, -1 = pas de gravité
var apply_gravity := true
var can_move := true # permets d'annuler le move and slide
var request_jump := false setget , get_request_jump # permets d'avoir un saut avec une certaine tolérance
var is_on_ground_with_delay := true # donne un  délai pour autoriser un saut en retard
var is_on_ground_with_delay_waiting := false
var is_force_applied := false # true si le player subit une force
var glissade_recovery := false
var request_new_state = null
var zoom_recovery := false
var can_climb := true # permts de définir si le player peut s'aggriper
onready var state_machine  := $StateMachine
onready var special_state_machine  := $SpecialStateMachine
onready var water_level  := $WaterLevel

func _ready() -> void:	
	name = "player"
	add_to_group("player")
	can_move = true
	state_machine.init()
	special_state_machine.init("None", "special_state")

	if Game.debug:
		debug_label = Label.new()
		debug_label.align = debug_label.ALIGN_CENTER
		debug_label.add_font_override("font", load("res://resources/montserrat.tres"))
		self.add_child(debug_label)
		
func _physics_process(delta):
	Engine.time_scale = Game.time_scale
	if Game.debug:
		var body_size = $body.texture.get_size()
		if special_state.name != "None":
			debug_label.text = special_state.name + "\n"
		debug_label.text = state.name + "\n" + str(velocity.floor())
		if debug_label_text:
			debug_label.text += "\n" + str(debug_label_text)
#		debug_label.rect_position = Vector2(-(body_size.x * $body.scale.x)/2 - 25, - 100)
		debug_label.rect_position = Vector2(-110, -200)
	if not is_on_floor() and can_move:
		if apply_gravity:
			velocity.y += Game.gravity * Game.gravity_factor * delta * Game.get_gravity_direction()
			if cap_gravity != 0:
				velocity.y = clamp(velocity.y, -1000, cap_gravity)
	if direction.x != 0:
		previous_direction = direction
	direction = _get_direction()
	
	# On verra plus tard si on ne place pas ca dans event
	if Input.is_action_just_pressed("fullscreen"):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())
	if Input.is_action_just_pressed("zoom") and not zoom_recovery:
		zoom_recovery = true
		Utils.is_zoom_required = true
		Game.time_scale = 0.2
		yield(get_tree().create_timer(0.35),"timeout")
		Utils.is_zoom_required = false
		Game.time_scale = 1	
		yield(get_tree().create_timer(1),"timeout")
		zoom_recovery = false

	_update_is_on_ground_with_delay()
	_update_request_jump()
	_update_sprite_transformation()

	if _is_on_water():
		state_machine._change_state("Swim", null, false)
	# State Machine Flow
	if request_new_state != null:
		state_machine._change_state(request_new_state.name, request_new_state.params)
		request_new_state = null
	state_machine.pre_update()
	special_state_machine.pre_update()
	state_machine.update()
	special_state_machine.update()
	if can_move:
		move()
	state_machine.post_update()
	special_state_machine.post_update()

func move() -> Vector2:
	var snap: Vector2 = Game.floor_normal * -1 * 2.0 if direction.y == 0.0 and state.name != "Jump" else Vector2.ZERO
	
	# On évite les valeurs extrêmes (force)
	velocity.x = clamp(velocity.x, -3200, 3200)
	velocity.y = clamp(velocity.y, -3200, 3200)
	
	velocity = move_and_slide_with_snap(velocity, snap, Game.floor_normal, true)
	return velocity

func _update_sprite_transformation() -> void:
	if Game.get_gravity_direction() == -1:
		$body.flip_v = true
	else:
		$body.flip_v = false
	
func set_dead(value: bool) -> void:
	state_machine._change_state("dead")
	set_process_input(not value)
	set_physics_process(not value)
	$CollisionShape2D.disabled = value

func apply_force(force: Vector2) -> void:
	# patch gravité au sol
	if force.y < 0 && is_on_floor():
		force.y = 0
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
		
func is_falling():
	return (Game.get_gravity_direction() == 1 and velocity.y > 0) or (Game.get_gravity_direction() == -1 and velocity.y < 0) 
	
func _update_request_jump() -> void:
	"""
		Permets d'avoir un temps petit temps de retard pour un saut, cela améliore fortement le gameplay
	"""
	if not request_jump and Input.is_action_just_pressed('jump'):
		request_jump = true
		yield(get_tree().create_timer(0.1),"timeout")
		request_jump = false
		
func _is_on_water() -> bool:
	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_point(water_level.global_position, 10, [], 128)
	return results.size() != 0

static func _get_direction() -> Vector2:
	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return direction

func get_anim_direction(center := false, custom_x_direction = null):
	# Si on ne veut pas utiliser la vélocité comme direction
	if custom_x_direction && center:
		if custom_x_direction == 0:
			return "C"
	if custom_x_direction:
		return "L" if custom_x_direction < 0 else "R"
		
	if velocity.x < 0:
		return "L"
	if velocity.x > 0:
		return "R"
	if center:
		return "C"
	return "L" if direction.x < 0 else "R"

func _on_ClimbTimer_timeout() -> void:
	can_climb = true
