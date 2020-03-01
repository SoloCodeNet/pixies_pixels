extends Node

signal state_changed(state_name)

const MAX_STATE_ITEM = 5
const states := []
var states_map := {}
var previous_state
var current_state
var owner_property_name

func init(default_state: String = "Idle", owner_property_name: String = "state", animation_node_name: String = "AnimationPlayer") -> void:
	"""
		Innitialise la state machine.
		"default_state": le state qui sera setté par défaut.
		"owner_property_name": le nom de la propriété du owner contenant cette statemachine
		"animation_node_name": le nom de l'animation player a utiliser avec cette statemachine
	"""
	self.owner_property_name = owner_property_name

	# si annimation player, on le connecte pour avoir un signal
	if animation_node_name:
		assert(owner.has_node(animation_node_name))
		owner.get_node(animation_node_name).connect("animation_finished", self, "_on_animation_finished")

	# installation des noeuds enfants
	for state_node in get_children():
		if state_node is StateNode:
			state_node.setup()
			if Game.debug:
				state_node.check_requirements()
			state_node.connect("finished", self, "_change_state") # connecte le signal pour sortir d'un état
			if animation_node_name:
				state_node.animation_player = owner.get_node(animation_node_name)
			for s in state_node.handled_states():
				states_map[s] = state_node


	# initialisation du premier state
	states.push_front({name = default_state, node = states_map[default_state]})
	owner[owner_property_name] = states[0]
	_change_state(default_state)

func pre_update() -> void:
	owner[owner_property_name].node.pre_update()

func update():
	owner[owner_property_name].node.update()

func post_update() -> void:
	owner[owner_property_name].node.post_update()

func _change_state(new_state_name: String, params = null, add_to_stack = true) -> void:
	"""
		Gère le changement de state.
		"new_state_name": le nom du prochain state
		"params": paramètre à passer au nouveau state
		"add_to_stack": détermine si on ajoute ce state à notre tableau "states". Jump a par exemple un sous-état Fall.
		A la fin d'un saut on veut retourner à l'état précédent, si on ajoute Fall à notre tableau, l'état de notre stack
		sera le suivant  Walk -> Jump -> Fall. Or on veut retourner à Walk et non à Jump,
		c'est pourquoi dans ce cas, on ne voudra pas ajouter le sous-état à "states"
	"""

	if new_state_name == owner[owner_property_name].name:
		return

	if Game.debug_state:
		print(new_state_name)

	if new_state_name == "previous":
		assert(states.size() > 1)
		states.pop_front()
		_change_state(states[0].name)
		return

	owner[owner_property_name].node.exit(new_state_name)	
	if new_state_name == "dead":
		return
	if not states_map.has(new_state_name):
		print("** SI TU VOIS CA DONNE MOI CETTE LIGNE ** : ", new_state_name)
	assert(states_map.has(new_state_name))
	var new_state = {name = new_state_name, node = states_map[new_state_name]}
	previous_state = owner[owner_property_name]
	owner[owner_property_name] = new_state
	current_state = new_state

	if add_to_stack and states[0].name != new_state_name:
		states.push_front(new_state)
		if(states.size() > MAX_STATE_ITEM):
			states.pop_back()
	
	owner[owner_property_name].node.enter(params, !add_to_stack)
	emit_signal("state_changed", owner[owner_property_name].name)

func _on_animation_finished(anim_name: String):
	owner[owner_property_name].node.on_animation_finished(anim_name)
