extends Node

var cam_posi = Vector2.ZERO setget set_cam_posi
var colorBackground : Color setget set_colorBackground, get_colorBackground

func set_cam_posi(value: Vector2):
	cam_posi = value
	
func set_colorBackground(value):
	colorBackground = value
	
func get_colorBackground():
	return colorBackground
