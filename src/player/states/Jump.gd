extends "res://src/global/Istate.gd"

# MOUVEMENT
export(float) var AIR_ACCELERATION_WALK := 3500.0
export(float) var AIR_ACCELERATION_RUN := AIR_ACCELERATION_WALK * 1.45
export(float) var AIR_FRICTION := 0
export(float) var MAX_AIR_SPEED_WALK := 400
export(float) var MAX_AIR_SPEED_RUN := 500
export(float) var SLIDE_FACTOR := 1.2
# JUMP
export(float) var JUMP_HEIGHT_VEL_WALK_MAX := -1420.0
export(float) var JUMP_HEIGHT_VEL_RUN_MAX := JUMP_HEIGHT_VEL_WALK_MAX * 1.15

export(float) var JUMP_HEIGHT_VEL_MIN := -400.0
# WALL SLIDE/JUMP
export(float) var WALL_JUMP_HEIGHT_WALK_AXE_X := 920.0
export(float) var WALL_JUMP_HEIGHT_RUN_AXE_X := 1320.0
export(float) var WALL_SLIDE_CAP_GRAVITY := 600
export(float) var WALL_JUMP_BOOST_VEL_AXE_Y = -2000

var is_running := false
var cancel_jump := false # Pour annuler un saut lors du relachement de la touche
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

# Dash
var can_dash = true

# WallJump Node
onready var left_wall_raycasts =  $WallRaycasts/WallRaycastsLeft
onready var right_wall_raycasts = $WallRaycasts/WallRaycastsRight
onready var bottom_wall_raycast = $WallRaycasts/WallRaycastBottom

# Climb Node
onready var climb_raycast_right =  $ClimbRayCasts/ClimbRayCastRight
onready var climb_raycast_wall_check_right =  $ClimbRayCasts/ClimbWallRayCastRight
onready var climb_raycast_left =  $ClimbRayCasts/ClimbRayCastLeft
onready var climb_raycast_wall_check_left =  $ClimbRayCasts/ClimbWallRayCastLeft

# Dash Node 
onready var dash_min_heigth = $MinDashRayCast

var can_climb = true
var climb_detach_do = false
var climb_direction = 0

var climb_node = null

func handled_states():
	return ["Jump", "Fall", "WallSlide", "WallJump", "Climb"]

func check_requirements():
	assert(owner.cap_gravity != null and has_node("WallRaycasts") and has_node("WallStickyTimer"))

func enter(params = null, sub_state = false):	

	if self.previous_state == "Dash":
		can_dash = false
	# Climb setup
	if self.current_state == "Climb":
		Game.gravity_factor = 0
		owner.velocity = Vector2.ZERO
		owner.can_move = false
		$ClimbTimer.start()

	# On applique l'impulsion du saut (seulement s'il était au sol)
	# and self.previous_state in ["Walk", "Run", "Idle", "Climb"] à tester
	if self.current_state == "Jump" and not self.previous_state in ["WallJump", "WallSlide"] :
		is_running = Input.is_action_pressed("run")
		if params != null and "vely" in params: # impulsion personnalisée
			owner.velocity.y = params.vely
		elif params != null: # pas r'impulsion
			pass
		else: # impulsion par défaut
			owner.velocity.y =  (JUMP_HEIGHT_VEL_RUN_MAX if is_running else JUMP_HEIGHT_VEL_WALK_MAX) * Game.get_gravity_direction()
	
	# On applique l'impusion du Walljump
	if self.current_state == "WallJump":
		is_running = Input.is_action_pressed('run')
		var wall_jump_force = WALL_JUMP_HEIGHT_RUN_AXE_X if is_running else WALL_JUMP_HEIGHT_WALK_AXE_X
		owner.velocity.x = can_wall_jump_direction * -1  * wall_jump_force
		# on saute en haut si on appuye l'inverse de la direction d'un saut.
		if self.previous_state == "Climb" and owner.direction.x == can_wall_jump_direction:
			owner.velocity.x = 0
		owner.velocity.y = WALL_JUMP_BOOST_VEL_AXE_Y * Game.get_gravity_direction()
		return sub_state("Jump")
	
		
func pre_update():
	if owner.is_on_floor() and owner.velocity.y == 0:
		nbr_wall_jump = 0
		can_dash = true
		return state("previous")
	
	prev_wall_direction = wall_direction
	_update_wall_direction()
	_update_can_wall_jump()
	
	if owner.is_force_applied:
		return sub_state("Fall")
	# Détection du climb
	if self.current_state != "Climb" && is_in_climb_position():
		nbr_wall_jump = 0
		return sub_state("Climb")
	# Détection plateforme qui disparaitrait
	if self.current_state == "Climb" && not is_in_climb_position():
		if climb_detach_do == false:
			climb_detach_do = true
			yield(get_tree().create_timer(1),"timeout")
			climb_detach_do = false
			if not not is_in_climb_position():
				nbr_wall_jump = 0
				return sub_state("Fall")
		return
	# Détection du climb jump
	if self.current_state == "Climb" && owner.request_jump:
		can_climb = false
		$ClimbTimer.start()
		if owner.direction.x == 0:
			return sub_state("Jump")
		else:
			return sub_state("WallJump")
	if self.current_state == "Climb" and Input.is_action_just_pressed("down"):
		can_climb = false
		$ClimbTimer.start()
		return sub_state("Fall")
	if self.current_state == "Climb": return # on reste dessus.
	# retour en WallSlide durant un saut
	if self.current_state in ["Jump", "Fall"] and Input.is_action_just_pressed('dash') and can_dash and owner.velocity.x != 0 and !dash_min_heigth.is_colliding():
		return sub_state("Dash")
	if self.current_state in ["Jump", "Fall"] and wall_direction != 0:
		return sub_state("WallSlide")
	# détection du WallJump
	if can_wall_jump and (MAX_WALL_JUMP < 0 or nbr_wall_jump < MAX_WALL_JUMP) and owner.request_jump:
		nbr_wall_jump += 1
		return sub_state("WallJump")
	# décrochage d'un WallSlide en cas d'un appuie long sur la direction opposée
	if self.current_state == "WallSlide" and owner.direction.x and owner.direction.x == -wall_direction and wall_slide_sticky == StickyMode.STICKY:
		wall_slide_sticky = StickyMode.WAITING
		$WallStickyTimer.start()
		return
	# arrêt du WallJump si plus de mur
	if self.current_state == "WallSlide" and wall_direction == 0:
		return sub_state("Fall" if owner.is_falling() else "Jump")
	# détection du WallSlide (sauf si le temps de recovery après un décrochage n'est pas terminé')
	if owner.is_falling() and wall_direction != 0 and wall_slide_sticky != StickyMode.NO_STICKY:
		return sub_state("WallSlide")
	# détection du Fall
	if owner.is_falling():
		return sub_state("Fall")
	# détection du Jump
	if Input.is_action_just_released("jump") and self.current_state == "Jump":
		cancel_jump = true

func update():
	# on regarde dans le sens inverse du mur en cas de WallSlide
	if self.current_state == "Climb":
		_update_animation(-1 * climb_direction)
	elif self.current_state == "WallSlide":
		_update_animation(-1 * wall_direction)
	else:
		_update_animation()

	if self.current_state == "Climb":
		if climb_node:
			owner.global_position.y = climb_node.node.global_position.y + climb_node.offset.y
		return
	elif self.current_state == "Dash":
		return
	
	var speed = AIR_ACCELERATION_RUN if is_running else AIR_ACCELERATION_WALK
	var max_speed = MAX_AIR_SPEED_RUN if is_running else MAX_AIR_SPEED_WALK

	# déccélération
	owner.velocity.x = move_toward(owner.velocity.x, 0, AIR_FRICTION * self.delta)
	
	# wall slide - on applique le ralentissement (cap) uniquement s'il tombe ou veux stopper
	if self.current_state == "WallSlide" and owner.is_falling():
		owner.cap_gravity = WALL_SLIDE_CAP_GRAVITY if owner.direction.y != 1 else 0 # Si bas on annule le cap
	# s'il monte on diminue la gravité pour qu'il glisse plus
	#elif self.current_state == "WallSlide" and owner.velocity.y < 0:
	#	Game.gravity_factor = .85
	#else: # on restore la gravité
#		Game.gravity_factor = 1

	# arrêt du saut
	if cancel_jump and owner.velocity.y < JUMP_HEIGHT_VEL_MIN * Game.get_gravity_direction() and self.current_state == "Jump":
		owner.velocity.y = lerp(owner.velocity.y, JUMP_HEIGHT_VEL_MIN * Game.get_gravity_direction(), 0.33)
	
	# accélération de la déscente quand on appuie bas
	if self.current_state in ["Fall", "Jump"] and Input.is_action_pressed('down'):
		owner.velocity.y = lerp(owner.velocity.y, 150 * Game.get_gravity_direction(), 0.05)
	
	# mouvement - on ne l'applique pas au WallSlide sauf si l'utilisateur insiste pour se libérer
	if owner.direction.x and (not self.current_state in ["WallSlide", "Climb"] or wall_slide_sticky ==  StickyMode.NO_STICKY):
		# application d'un facteur slide si changement de direction en mouvement
		if owner.velocity.x and not sign(owner.velocity.x) == sign(owner.direction.x):
			owner.velocity.x += owner.direction.x * speed * self.delta * SLIDE_FACTOR
		elif abs(owner.velocity.x) < max_speed:
			owner.velocity.x += owner.direction.x * speed * self.delta
			
	# limitation de la vitesse
	#if abs(owner.velocity.x) > max_speed  :
	#	owner.velocity.x  = lerp(owner.velocity.x , sign(owner.velocity.x) * max_speed, 0.05)
	
func exit(new_state):
	if current_state == "WallSlide" : 
		owner.cap_gravity = 0 # restaure la gravité quand on quite le WallSlide
	elif current_state == "Climb" :
		Game.gravity_factor = 1
		owner.can_move = true
		climb_direction = 0
		climb_node = null
		
	cancel_jump = false

func is_in_climb_position():
	if self.current_state == "Climb":
		if not climb_raycast_wall_check_right.is_colliding() if climb_direction == 1 else not climb_raycast_wall_check_left.is_colliding():
			return false
		return true
	climb_direction = 0 # reset
	climb_node = null
	if not can_climb or not owner.is_falling() or climb_raycast_right.is_colliding() or climb_raycast_left.is_colliding():
		return false
	if climb_raycast_wall_check_right.is_colliding():
		climb_direction = 1
		var object = climb_raycast_wall_check_right.get_collider()
		var normal = climb_raycast_wall_check_right.get_collision_normal()
		_set_climb_node(object, normal, 1)
		return true
	elif climb_raycast_wall_check_left.is_colliding():
		climb_direction = -1
		var object = climb_raycast_wall_check_left.get_collider()
		var normal = climb_raycast_wall_check_left.get_collision_normal()
		_set_climb_node(object, normal, -1)
		return true
	return false
	
func _set_climb_node(collider, normal, offset):
	if not collider.is_in_group("moving_platform"):
		return
	
	if collider is KinematicBody2D:
		climb_node = {
			node = collider,
			offset = Vector2(0, 50) # 50 c'est arbitraire, cela rend mieux
		}
	elif collider is TileMap:
		var moving_plat : Node2D = collider.get_parent()
		var current_pos = moving_plat.global_position
		var begin_pos = moving_plat.start_point
		var end_pos = moving_plat.end_point
		var tilemap_start = moving_plat.wall_topleft_position.global_position
	
		print("TM Pos: ", current_pos.y, " TM start: ", begin_pos.y, " TM end: ", end_pos.y, " Relative Start: ", tilemap_start.y, " Player : ", owner.position.y)
		var offset_tile = abs(current_pos.y - tilemap_start.y)
		var offset_player = abs(tilemap_start.y - owner.position.y)
		print("Offset Tilemap : ", offset_tile, " Offset_player : ", offset_player)
		climb_node = {
			node = moving_plat,
			offset = Vector2(0, offset_player + offset_tile + 5)
		}

func _update_can_wall_jump():
	if current_state == "WallSlide" and prev_wall_direction != 0 and wall_direction == 0 and not can_wall_jump_wait:
		can_wall_jump = true
		can_wall_jump_wait = true
		can_wall_jump_direction = prev_wall_direction
		yield(get_tree().create_timer(0.1),"timeout")
		can_wall_jump_wait = false
		if wall_direction == 0 and current_state != "WallSlide":
			can_wall_jump = false
	if current_state == "WallSlide" and wall_direction != 0 : 
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


func _on_ClimbTimer_timeout() -> void:
	can_climb = true
	
func _update_animation(direction = null):
	if self.current_state == "WallSlide" || self.current_state == "Climb":
		self.change_anim("climb_", true, false, direction)
	elif self.current_state == "Fall":
		self.change_anim("fall_", true, true, direction)
	else:
		self.change_anim("jump_", true, true, direction)
	
