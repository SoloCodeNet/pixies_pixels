extends "res://src/global/Istate.gd"

# MOUVEMENT
var AIR_ACCELERATION_WALK := 3500.0
var AIR_ACCELERATION_RUN := AIR_ACCELERATION_WALK * 1.45
var AIR_FRICTION := 0
var MAX_AIR_SPEED_WALK := 400
var MAX_AIR_SPEED_RUN := 500
var SLIDE_FACTOR := 1.2
# JUMP
var JUMP_HEIGHT_VEL_WALK_MAX := -1420.0
var JUMP_HEIGHT_VEL_RUN_MAX := JUMP_HEIGHT_VEL_WALK_MAX * 1.15
var JUMP_HEIGHT_VEL_MIN := -400.0


var is_running := false
var cancel_jump := false # Pour annuler un saut lors du relachement de la touche

# State Nodes
onready var node_wallslide = $"../WallSlide"
onready var node_dash = $"../Dash"
onready var node_climb = $"../Climb"

func handled_states():
	return ["Jump", "Fall"]

func enter(params = null, sub_state = false):	
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
		
func pre_update():
	if owner.is_on_floor() and owner.velocity.y == 0:
		node_wallslide.nbr_wall_jump = 0
		node_dash.can_dash = true
		return state("previous")
	if owner.is_force_applied:
		return sub_state("Fall")
	# Détection du climb
	if owner.is_falling() and node_climb.is_in_climb_position():
		node_wallslide.nbr_wall_jump = 0
		return sub_state("Climb")

	if node_dash.is_request_dash():
		return sub_state("Dash")

	node_wallslide._update_walljump()
	# retour en WallSlide durant un saut
	if node_wallslide.wall_direction != 0:
		return sub_state("WallSlide")
	# détection du WallSlide (sauf si le temps de recovery après un décrochage n'est pas terminé')
	if owner.is_falling() and node_wallslide.is_ready_walljump():
		return sub_state("WallSlide")
	# détection du Fall
	if owner.is_falling():
		return sub_state("Fall")
	# détection du Jump
	if Input.is_action_just_released("jump") and self.current_state == "Jump":
		cancel_jump = true

func update():
	# on regarde dans le sens inverse du mur en cas de WallSlide
	self.change_anim("fall_" if owner.is_falling() else "jump_", true, true)
	
	var speed = AIR_ACCELERATION_RUN if is_running else AIR_ACCELERATION_WALK
	var max_speed = MAX_AIR_SPEED_RUN if is_running else MAX_AIR_SPEED_WALK

	# déccélération
	owner.velocity.x = move_toward(owner.velocity.x, 0, AIR_FRICTION * self.delta)
	
	# arrêt du saut
	if cancel_jump and owner.velocity.y < JUMP_HEIGHT_VEL_MIN * Game.get_gravity_direction() and self.current_state == "Jump":
		owner.velocity.y = lerp(owner.velocity.y, JUMP_HEIGHT_VEL_MIN * Game.get_gravity_direction(), 0.33)
	
	# accélération de la déscente quand on appuie bas
	if Input.is_action_pressed('down'):
		owner.velocity.y = lerp(owner.velocity.y, 150 * Game.get_gravity_direction(), 0.05)
	
	# mouvement - on ne l'applique pas au WallSlide sauf si l'utilisateur insiste pour se libérer
	if owner.direction.x:
		# application d'un facteur slide si changement de direction en mouvement
		if owner.velocity.x and not sign(owner.velocity.x) == sign(owner.direction.x):
			owner.velocity.x += owner.direction.x * speed * self.delta * SLIDE_FACTOR
		elif abs(owner.velocity.x) < max_speed:
			owner.velocity.x += owner.direction.x * speed * self.delta

func exit(new_state):
	cancel_jump = false
