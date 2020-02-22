extends Node2D
onready var scene = get_parent()
onready var lbl1 = $cl/mc/vbox/lbl1
onready var lbl2 = $cl/mc/vbox/lbl2
onready var lbl3 = $cl/mc/vbox/lbl3
onready var lbl4 = $cl/mc/vbox/lbl4
onready var cam  := $Camera2D
onready var tw   := $Tween
onready var grid := $TileMap

signal update_posi()

var size_scene: Rect2
var old_pos   : Vector2 = Vector2(-10, -10)
var fixedcam  : bool = true
var old_zoom  : Vector2
var new_zoom  : Vector2
var cuts: Vector2

func start(cut: Vector2, size: Rect2, default_zoom,fixed = false):
	fixedcam = fixed
	size_scene = size
	grid.cell_size = size_scene.size / cut
	cuts = cut
	cam.limit_left = size_scene.position.x
	cam.limit_top = size_scene.position.y
	cam.limit_right = size_scene.size.x - size_scene.position.x
	cam.limit_bottom = size_scene.size.y - size_scene.position.y
	if fixedcam  == false :
		emit_signal("update_posi")
		cam.zoom = default_zoom
	
func _ready() -> void:
	get_tree().get_root().connect("size_changed", self, "resize")
	
func update_zoom(zo:Vector2):
	new_zoom
	
func resize():
	if fixedcam:
		update_cam(grid.world_to_map(scene.pos_player), true)
	
func _process(delta: float) -> void:
	if fixedcam:
		update_cam(grid.world_to_map(scene.pos_player))
		lbl4.text = "FPS: " + str(Engine.get_frames_per_second())
	else:
		self.global_position = lerp(self.global_position, scene.pos_player, 0.05)
	
func update_cam(grid_pos:Vector2, forced:bool= false):
	if grid_pos.x < 0 or grid_pos.x > cuts.x-1 or grid_pos.y < 0 or grid_pos.y > cuts.y-1: 
		return #permet de ne pas update si on sort de la zone définie
	if old_pos == grid_pos and !forced:
		return

	var grid_rect = Rect2(grid.cell_size * grid_pos, grid.cell_size)
	var v = Vector2(
		grid_rect.position.x + (grid_rect.size.x / 2),
		grid_rect.position.y + (grid_rect.size.y / 2)
	)
	tw.interpolate_property(cam, "position", cam.position, v, 1.0, Tween.TRANS_CIRC,Tween.EASE_OUT)
	tw.start()
	old_pos = grid_pos
	
	var zo:Vector2
	zo.x = grid_rect.size.x / ProjectSettings.get("display/window/size/width")
	zo.y = grid_rect.size.y / ProjectSettings.get("display/window/size/height")
	cam.zoom = zo
#	$Camera2D/paraback/paralay/fond.scale = zo
	lbl1.text = "cell size: " + str(grid.cell_size)
	lbl2.text = "zoom: " + str(zo)
	lbl3.text = "real screen pixel: " + str(grid_rect.size) 
	emit_signal("update_posi")
	
func zoomed():
	pass
