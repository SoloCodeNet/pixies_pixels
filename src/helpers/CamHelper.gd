extends Node2D
onready var scene = get_parent()
onready var cam:Camera2D = $Camera2D
var _board:Rect2
var _grd_sz: Vector2
var _plyr: KinematicBody2D
var _fixed: bool
var old_pos : Vector2 = Vector2(0, -1)
var new_pos : Vector2
var nrm_zoom: Vector2
var nrm_posi: Vector2
var _free_zoom:Vector2
func start(cut: Vector2, board: Rect2, default_zoom: Vector2, fixed:bool = true):
	_board = board
	_grd_sz = board.size / cut
	_fixed = fixed
	_free_zoom = default_zoom
	$grid.cell_size = _grd_sz
	nrm_zoom.x = _grd_sz.x / ProjectSettings.get("display/window/size/width")
	nrm_zoom.y = _grd_sz.y / ProjectSettings.get("display/window/size/height")
	cam.zoom = nrm_zoom if _fixed else _free_zoom

func _physics_process(_delta: float) -> void:
	var pos_player = Utils.player_posi
	new_pos = $grid.world_to_map(pos_player)
	var rec:= Rect2(_grd_sz * new_pos, _grd_sz) if _fixed else _board
	
	cam.limit_left  = rec.position.x
	cam.limit_top   = rec.position.y
	cam.limit_right = rec.position.x + rec.size.x
	cam.limit_bottom= rec.position.y + rec.size.y

#	cam.position = rec.position+ (rec.size / 2)
	nrm_posi = rec.position+ (rec.size / 2)
	cam.position = pos_player
	var zoom = nrm_zoom if _fixed else _free_zoom
	if Utils.is_zoom_required: # avec zoom 
		cam.zoom = lerp(cam.zoom, zoom  / 2, 0.2)
	elif cam.zoom != nrm_zoom:
		cam.zoom.x = move_toward(cam.zoom.x, zoom.x, zoom.x/10)
		cam.zoom.y = move_toward(cam.zoom.y, zoom.y, zoom.y/10)
		
func _process(delta: float) -> void:
	pass
	
	

#onready var scene = get_parent()
#onready var lbl1 = $cl/mc/vbox/lbl1
#onready var lbl2 = $cl/mc/vbox/lbl2
#onready var lbl3 = $cl/mc/vbox/lbl3
#onready var lbl4 = $cl/mc/vbox/lbl4
#onready var cam  := $Camera2D
#onready var tw   := $Tween
#onready var grid := $TileMap
#
#signal update_posi()
#
#var size_scene: Rect2
#var old_pos   : Vector2 = Vector2(-10, -10)
#var fixedcam  : bool = true
#var old_zoom  : Vector2
#var new_zoom  : Vector2
#var cuts: Vector2
#var zo1:Vector2
#var zo2;
#var zoomed: bool 
#var grid_rect:Rect2
#var posi_deplace:Vector2
#var posi_start: Vector2
#
#func start(cut: Vector2, size: Rect2, default_zoom,fixed = false):
#	fixedcam = fixed
#	size_scene = size
#	grid.cell_size = size_scene.size / cut
#	cuts = cut
#	cam.limit_left = size_scene.position.x
#	cam.limit_top = size_scene.position.y
#	cam.limit_right = size_scene.size.x - size_scene.position.x
#	cam.limit_bottom = size_scene.size.y - size_scene.position.y
#	if fixedcam  == false :
#		emit_signal("update_posi")
#		cam.zoom = default_zoom
#
#func _ready() -> void:
#	get_tree().get_root().connect("size_changed", self, "resize")
#
#func update_zoom(zo:Vector2):
#	new_zoom
#
#func resize():
#	if fixedcam:
#		update_cam(grid.world_to_map(scene.pos_player), true)
#
#func _process(delta: float) -> void:
#	zoomed = Input.is_action_pressed("zoom")
#	if fixedcam:
#		update_cam(grid.world_to_map(scene.pos_player))
#		lbl4.text = "FPS: " + str(Engine.get_frames_per_second())
#	else:
#		self.global_position = lerp(self.global_position, scene.pos_player, 0.05)
#
#	var cam2 = scene.player_cam
#	if zoomed:
#		cam.global_position = lerp(cam.position, scene.pos_player, 0.01)
#		cam.zoom     = lerp(cam.zoom, cam2.zoom, 0.01)
#	else: 
#		cam.global_position = lerp(cam.position, posi_start, 0.1 )
#		cam.zoom     = lerp(cam.zoom, zo1, 0.1)
#
#func update_cam(grid_pos:Vector2, forced:bool= false):
#	if grid_pos.x < 0 or grid_pos.x > cuts.x-1 or grid_pos.y < 0 or grid_pos.y > cuts.y-1: 
#		return #permet de ne pas update si on sort de la zone définie
#	if old_pos == grid_pos and !forced:
#		return
#
#	grid_rect = Rect2(grid.cell_size * grid_pos, grid.cell_size)
#	posi_deplace = Vector2(
#		grid_rect.position.x + (grid_rect.size.x / 2),
#		grid_rect.position.y + (grid_rect.size.y / 2)
#	)
#	posi_start = cam.position
#	tw.interpolate_property(cam, "position", posi_start, posi_deplace, 1.0, Tween.TRANS_CIRC,Tween.EASE_OUT)
#	tw.start()
#	old_pos = grid_pos
#
#
#	zo1.x = grid_rect.size.x / ProjectSettings.get("display/window/size/width")
#	zo1.y = grid_rect.size.y / ProjectSettings.get("display/window/size/height")
#
##	$Camera2D/paraback/paralay/fond.scale = zo
#	lbl1.text = "cell size: " + str(grid.cell_size)
#	lbl2.text = "zoom: " + str(zo1)
#	lbl3.text = "real screen pixel: " + str(grid_rect.size) 
#	emit_signal("update_posi")
	

