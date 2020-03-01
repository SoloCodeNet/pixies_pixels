extends Node

# Valeures globales
var time_scale = 1
var gravity := 4000.0
var gravity_factor := 1.0 # permets de diminuer ou augmenter la graviter
var tile_size = 8
var floor_normal = Vector2.UP

# Debug
const debug = false
const debug_player = true
const debug_enemies = true
const debug_state = false

func get_gravity_direction() -> int :
	return Game.floor_normal.y * -1
