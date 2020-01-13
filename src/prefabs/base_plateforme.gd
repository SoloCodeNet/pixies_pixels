extends Node2D


onready var back   = $back_tile
onready var base   = $collision
onready var pieges = $pieges
onready var traps  = $traps

func _ready() -> void:
	add_traps()
	
func add_traps():
	for tile in pieges.get_used_cells():
		var s 
		var index = pieges.get_cellv(tile)
		if index == 0: # spades
			s = preload("res://src/prefabs/traps/spades.tscn").instance()
			s.rotation_degrees = angle_tile(tile,pieges)
		if index == 1: # falling no break
			s = preload("res://src/prefabs/traps/falling_rest.tscn").instance()
		if index == 2: # falling with break
			s = preload("res://src/prefabs/traps/falling.tscn").instance()
		if index == 3: # cycle
			s = preload("res://src/prefabs/traps/cycle.tscn").instance()
		s.position =  pieges.map_to_world(tile) + Vector2(4,4)
		pieges.set_cellv(tile, -1)
		traps.add_child(s)

			
func angle_tile(tile:Vector2, tm:TileMap) -> float:
	var ang = 0.0
	var t := tm.is_cell_transposed(tile.x, tile.y)
	var x := tm.is_cell_x_flipped(tile.x, tile.y)
	var y := tm.is_cell_y_flipped(tile.x, tile.y)
	if t && !x && y : ang = 270.0
	if t && x && !y : ang = 90.0
	if !t && x && y: ang = 180.0
	return ang
