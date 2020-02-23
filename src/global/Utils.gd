extends Node

var is_zoom_required: bool 
var player_posi: Vector2  
var cam_posi = Vector2.ZERO setget set_cam_posi
var colorBackground : Color setget set_colorBackground, get_colorBackground

func set_player_posi(value:Vector2):
	player_posi = value
	
func get_player_posi() -> Vector2:
	return player_posi

func set_cam_posi(value: Vector2):
	cam_posi = value
	
func set_colorBackground(value):
	colorBackground = value
	
func get_colorBackground():
	return colorBackground
