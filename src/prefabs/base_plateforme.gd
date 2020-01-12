extends Node2D

#var l_up = [1,1,2,2,2,2,2,3,4,5,6,7]
#var l_dw = [8,9,10,11,12,13,14]
onready var back = $back_tile
onready var base = $base_tile

func _ready() -> void:
#	for tile in base.get_used_cells_by_id(0):
#		if base.get_cellv(tile+Vector2(0,-1)) == -1:
#			base.set_cellv(tile+Vector2(0,-1), l_up[randi()%l_up.size()])
#		if base.get_cellv(tile+Vector2(0,1)) == -1:
#			base.set_cellv(tile+Vector2(0,1), l_dw[randi()%l_dw.size()])
	pass
