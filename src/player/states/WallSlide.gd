extends "res://src/global/Istate.gd"

# WALL SLIDE/JUMP
var WALL_JUMP_HEIGHT_WALK_AXE_X := 920.0
var WALL_JUMP_HEIGHT_RUN_AXE_X := 1320.0
var WALL_SLIDE_CAP_GRAVITY := 600
var WALL_JUMP_BOOST_VEL_AXE_Y = -2000

onready var left_wall_raycasts =  $'../../StateNodes/WallRaycasts/WallRaycastsLeft'
onready var right_wall_raycasts = $'../../StateNodes/WallRaycasts/WallRaycastsRight'
onready var bottom_wall_raycast = $'../../StateNodes/MinGroundDistance'
onready var node_wall_sticky_timer = $'../../StateNodes/WallStickyTimer'

var wall_direction := 0 # Direction de contact avec un mur (-1 gauche, 0 rien, 1 droite)
var prev_wall_direction := 0
# Permets de tester s’il y a un appui long lors d'un wallslide pour se décrocher
enum StickyMode {STICKY, NO_STICKY, WAITING} 
var wall_slide_sticky = StickyMode.STICKY
# Permets un retard sur le walljump
var can_wall_jump = false
var can_wall_jump_wait = false
var can_wall_jump_direction = 0
var nbr_wall_jump = 0
export(int) var MAX_WALL_JUMP := -1 # < 0 = infinity

onready var node_climb =  $"../Climb"

func check_requirements():
	assert(has_node("../../StateNodes/WallRaycasts") and has_node("../../StateNodes/WallStickyTimer"))
			
func handled_states():
	return ["WallSlide", "WallJump"]

func enter(params = null, sub_state = false):
	if self.current_state == "WallJump":
		var wall_jump_force = WALL_JUMP_HEIGHT_RUN_AXE_X if Input.is_action_pressed('run') else WALL_JUMP_HEIGHT_WALK_AXE_X
		owner.velocity.x = can_wall_jump_direction * -1  * wall_jump_force
		# on saute en haut si on appuye l'inverse de la direction d'un saut.
		if self.previous_state == "Climb" and owner.direction.x == can_wall_jump_direction:
			owner.velocity.x = 0
		owner.velocity.y = WALL_JUMP_BOOST_VEL_AXE_Y * Game.get_gravity_direction()
		return sub_state("Jump")

func pre_update():
	if self.current_state == "WallJump":
		return
	_update_walljump()
	# détection du WallJump
	if can_wall_jump and (MAX_WALL_JUMP < 0 or nbr_wall_jump < MAX_WALL_JUMP) and owner.request_jump:
		nbr_wall_jump += 1
		return sub_state("WallJump")
	# Détection du climb
	if owner.is_falling() and node_climb.is_in_climb_position():
		nbr_wall_jump = 0
		return sub_state("Climb")
	# décrochage d'un WallSlide en cas d'un appuie long sur la direction opposée
	if owner.direction.x and owner.direction.x == -wall_direction and wall_slide_sticky == StickyMode.STICKY:
		wall_slide_sticky = StickyMode.WAITING
		node_wall_sticky_timer.start()
		return
	if wall_slide_sticky == StickyMode.NO_STICKY:
		return sub_state("Fall")
	# arrêt du WallSlide si plus de mur
	if wall_direction == 0:
		return sub_state("Fall" if owner.is_falling() else "Jump")
	
func update():
	self.change_anim("climb_", true, false, -1 * wall_direction)
	
	# wall slide - on applique le ralentissement (cap) uniquement s'il tombe ou veux stopper
	if owner.is_falling():
		owner.cap_gravity = WALL_SLIDE_CAP_GRAVITY if owner.direction.y != 1 else 0 # Si bas on annule le cap
	
func exit(new_state):
	wall_slide_sticky = StickyMode.STICKY
	owner.cap_gravity = 0 # restaure la gravité quand on quite le WallSlide

func is_ready_walljump() -> bool:
	return wall_direction != 0 and wall_slide_sticky != StickyMode.NO_STICKY

func _update_walljump():
	prev_wall_direction = wall_direction
	_update_wall_direction()
	_update_can_wall_jump()

func _update_can_wall_jump():
	if self.current_state == "WallSlide" and prev_wall_direction != 0 and wall_direction == 0 and not can_wall_jump_wait:
		can_wall_jump = true
		can_wall_jump_wait = true
		can_wall_jump_direction = prev_wall_direction
		yield(get_tree().create_timer(0.1),"timeout")
		can_wall_jump_wait = false
		if wall_direction == 0 and self.current_state != "WallSlide":
			can_wall_jump = false
	if self.current_state == "WallSlide" and wall_direction != 0 : 
		can_wall_jump = true
		can_wall_jump_direction = wall_direction
	elif not can_wall_jump_wait:
		can_wall_jump = false
		

func _update_wall_direction():
	"""
		Méthode qui met à jour la variable indiquant le sens du wall slide (0 s'il y en a pas')
		Il teste en premier  la Raycast du bas pour voir si la distance minimum est présente.
		Ensuite il vérifie le mur droit et gauche.
		S’il y a collision des deux côtés, la direction est laissée au choix de l'utilisateur.
	"""
	if bottom_wall_raycast.is_colliding():
		wall_direction = 0
		return
	
	var left = _is_on_wall(left_wall_raycasts)
	var right = _is_on_wall(right_wall_raycasts)
	
	if left and right:
		wall_direction = owner.direction.x
	else:
		wall_direction = -int(left) + int(right)
	
func _is_on_wall(wall_raycasts: Node) -> bool:
	"""
		Vérifie les raycasts pour s'il y a état de WallSlide. Pour se faire en plus de collision,
		on vérifie que l'angle de collision est égal à 90°
		wall_raycasts: un noeud contenant des raycasts 
	"""
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot = rad2deg(acos(Game.floor_normal.dot(raycast.get_collision_normal())))
			if dot == 90:
				return true
	return false


func _on_WallStickyTimer_timeout() -> void:
	"""
		Lorsque l'utilisateur appuie assez longtemps sur la direction opposée au mur, on le libère
	"""
	if not owner.direction and owner.direction. x == -wall_direction:
		wall_slide_sticky = StickyMode.STICKY
		return
	wall_slide_sticky = StickyMode.NO_STICKY
	yield(get_tree().create_timer(0.4),"timeout")
	wall_slide_sticky = StickyMode.STICKY
