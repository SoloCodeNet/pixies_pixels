extends "res://src/global/Istate.gd"

# Climb Node
onready var climb_raycast_right: RayCast2D =  $'../../StateNodes/ClimbRayCasts/ClimbRayCastRight'
onready var climb_raycast_wall_check_right: RayCast2D =  $'../../StateNodes/ClimbRayCasts/ClimbWallRayCastRight'
onready var climb_raycast_left: RayCast2D =  $'../../StateNodes/ClimbRayCasts/ClimbRayCastLeft'
onready var climb_raycast_wall_check_left : RayCast2D=  $'../../StateNodes/ClimbRayCasts/ClimbWallRayCastLeft'

onready var node_climb_timer : Timer = $'../../StateNodes/ClimbTimer'
onready var climb_min_heigth : RayCast2D = $'../../StateNodes/MinGroundDistance'

var climb_detach_do := false
var climb_direction := 0
var climb_node = null

enum ClimbStatus {NORMAL, WAITING, DETACH} 
var climb_status = ClimbStatus.NORMAL

func enter(params = null, sub_state = false):
	Game.gravity_factor = 0
	owner.velocity = Vector2.ZERO
	owner.can_move = false

func pre_update():
	# Détection plateforme qui disparaitrait
	if climb_status == ClimbStatus.DETACH:
		return sub_state("WallSlide")
	if not is_no_more_in_climb():
		if climb_status == ClimbStatus.NORMAL:
			climb_status = ClimbStatus.WAITING
			yield(get_tree().create_timer(0.3),"timeout")
			if climb_status == ClimbStatus.WAITING and not not is_no_more_in_climb():
				climb_status = ClimbStatus.DETACH
			else:
				climb_status = ClimbStatus.NORMAL
		return
	# Détection du climb jump
	if owner.request_jump:
		if owner.direction.x == 0:
			return sub_state("Jump")
		else:
			return sub_state("WallJump")
	if Input.is_action_just_pressed("down"):
		return sub_state("WallSlide")

func update():
	self.change_anim("climb_", true, false, -1 * climb_direction)
	if climb_node:
		print("climb node ", climb_node)
		owner.global_position.y = climb_node.node.global_position.y + climb_node.offset.y

func exit(new_state):
	Game.gravity_factor = 1
	owner.can_move = true
	climb_direction = 0
	climb_node = null
	owner.can_climb = false
	node_climb_timer.start()
	climb_status = ClimbStatus.NORMAL

func is_no_more_in_climb():
	if not climb_raycast_wall_check_right.is_colliding() if climb_direction == 1 else not climb_raycast_wall_check_left.is_colliding():
		return false
	return true

func is_in_climb_position():
	climb_direction = 0 # reset
	climb_node = null
			
	if not owner.can_climb or not owner.is_falling() or climb_raycast_right.is_colliding() or climb_raycast_left.is_colliding() or climb_min_heigth.is_colliding() :
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
