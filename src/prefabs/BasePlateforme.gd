extends Node2D

var l1 = [10,11,12,13,14,15,16,17,18,19]

onready var back   = $back_tile
onready var base   = $collision
onready var pieges = $pieges
onready var traps  = $traps

func _ready() -> void:
	randomize()
	pieges.visible = false
	add_traps()
	for cell in $collision.get_used_cells_by_id(0):
		$back_tile.set_cellv(cell, randi()% 15)
		if $collision.get_cellv(cell+ Vector2.UP)==-1:
			$collision.set_cellv(cell, l1[randi()% l1.size()] )
		else:
			$collision.set_cellv(cell, randi()% 10 )
	
func remove_traps():
	if traps.get_child_count() > 0:
		for x in traps.get_children():
			traps.remove_child(x)
	
	
	
func add_traps():
	var col = Color(randf(),randf(), randf())
	for tile in pieges.get_used_cells():
		var s 
		var index = pieges.get_cellv(tile)
		if index == 0: # spades
			s = preload("res://src/prefabs/traps/Spades.tscn").instance()
			s.rotation_degrees = angle_tile(tile,pieges)
		if index == 1: # falling no break
			s = preload("res://src/prefabs/traps/FallingRest.tscn").instance()
		if index == 2: # falling with break
			s = preload("res://src/prefabs/traps/Falling.tscn").instance()
		if index == 3: # cycle
			s = preload("res://src/prefabs/traps/Cycle.tscn").instance()
		if index == 4: # cycle
			s = preload("res://src/prefabs/traps/SpawnTrap.tscn").instance()
		s.position =  pieges.map_to_world(tile) + Vector2(4,4)
		s.modulate = col
		traps.call_deferred("add_child", s)

func angle_tile(tile:Vector2, tm:TileMap) -> float:
	var ang = 0.0
	var t := tm.is_cell_transposed(int(tile.x), int(tile.y))
	var x := tm.is_cell_x_flipped(int(tile.x), int(tile.y))
	var y := tm.is_cell_y_flipped(int(tile.x), int(tile.y))
	if t && !x && y : ang = 270.0
	if t && x && !y : ang = 90.0
	if !t && x && y: ang = 180.0
	return ang
	

