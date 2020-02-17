extends Node
class_name StateNode

# signal le changement d'un état
signal finished(next_state_name, params)

var delta setget , get_delta
var current_state
var previous_state
var animation_player: AnimationPlayer

# permets de vérifier que les propriétés/noeuds dont le state a besoin sont présentes
func check_requirements():
	pass

# permets d'initialiser des valeurs
func setup():
	pass
# permets d'accéder simplement à ces valeurs dans un state
func _setup_enter(new_state, previous_state):
	self.current_state = new_state
	self.previous_state = previous_state
	
# initialisation du state (animation, etc.)
func enter(params = null, sub_state = false):
	pass

# sortie du state (reset de valeurs, etc.)
func exit(new_state):
	pass

# avant l'update (on vérifie qu'on ne doit pas changer de state)
func pre_update():
	pass

# update le state
func update():
	pass

# après l'update ET le move_and_snap
func post_update():
	pass

# retourne le noms des states que le noeud gère
func handled_states() -> Array:
	return [name]

# lorsqu'une animation se termine (si un AnimationPlayer a été donné à la statemachine)
func on_animation_finished(anim_name):
	pass

# facilité d'écriture
func get_delta():
	return get_physics_process_delta_time()

# raccourci pour changer de state (avec un test pour éviter un signal inutile)
func state(state: String, params = null, add_to_stack = true) -> void:
	if current_state != state:
		emit_signal("finished", state, params, add_to_stack)
		
# comme le précédent sauf qu'il ne sera pas dans l'historique utilisé par l'état "previous", utile pour les états internes
func sub_state(state: String, params = null) -> void:
	state(state, params, false)
	
func change_anim(name: String, append_direction := false, center_direction := false, custom_x_direction = null) -> void:
	if animation_player:
		if append_direction and center_direction:
			animation_player.play(name + owner.get_anim_direction(true, custom_x_direction))
		elif append_direction and not center_direction:
			animation_player.play(name + owner.get_anim_direction(false, custom_x_direction))
		else:
			animation_player.play(name)
