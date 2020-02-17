tool
extends Node2D
const cell_size := 8
onready var spawn   = $spawn_player
onready var base_platform = $base_plateforme
onready var _cam    = preload("res://src/helpers/cam_helper.tscn")
onready var _player = preload("res://src/player/Player_16.tscn")
var real_rect:Rect2
var pos_player: Vector2
var player : KinematicBody2D
var cam    : Node2D


# ****************************   TOOLS
enum formes { FORM_16_9, FORM_16_10, FORM_4_3, FORM_1_1 }
### for fixed cam flase the zoom level is adjustable 
export (bool) var fog: = true
export (float) var default_zoom := 2.0
export (bool) var fixed_cam := true
export (formes) var forme := 0 setget set_form
export (bool) var debug_mode := true setget set_debug 
export (Vector2) var cut := Vector2(2,2) setget set_cut
export (int) var nbr_width := 16 setget set_nbr
export (Color) var gridColor := Color.red setget set_gridColor
export (Color) var ModulateGround := Color.black 
export (Color) var ModulateItems  := Color.darkgray
var ratio : float = 1.77777777777

func _init() ->void:
	update()
	
func _enter_tree() -> void:
	forme = 0
	update()
	
func set_form(value: int) -> void:
	match value:
		formes.FORM_1_1:
			ratio = 1.0
		formes.FORM_16_9:
			ratio = 1.7777777
		formes.FORM_16_10:
			ratio = 1.6666666
		formes.FORM_4_3:
			ratio = 1.3333333
	forme = value
	update()
	
func set_debug(bo:bool)-> void:
	debug_mode = bo 
	update()
	
func set_cut(vec: Vector2) -> void:
	cut = vec
	update()
	
func set_nbr(nbr: int)-> void:
	nbr_width = nbr
	update()
	
func set_gridColor(col:Color) ->void:
	gridColor = col
	update()
	
func _draw() -> void:
	if debug_mode :
		var w:float =  (cell_size * nbr_width)
		var h: float = w / ratio
	
		for x in range(cut.x +1):
			draw_line(Vector2(w * x, 0), Vector2(w * x, h * cut.y), gridColor, 2.0)
			
		for y in range(cut.y + 1):
			draw_line(Vector2(0, h * y), Vector2(w * cut.x, h * y), gridColor, 2.0)
# ****************************   TOOLS
func _ready() -> void:
#	for nodes in $Tilemaps.get_children():
#		nodes.connect("kill", self, "player_dead")
	real_rect = real_tile_size()
	spawn_player()
	spawn_cam()
	
#	Utils.set_colorBackground(ModulateGround)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		var err: = get_tree().reload_current_scene()
		if err != 0: print("relaod: ", err)
		
	if player != null && player.position != pos_player:
		pos_player = player.position
	
func spawn_cam():
	cam = _cam.instance()
#	var err = cam.connect("update_posi", self, "redraw_blocks")
#	if err != 0 : print("connection erreur: ", err)
	cam.position = Vector2.ZERO
	add_child(cam)
	cam.start(cut, real_rect, Vector2(default_zoom, default_zoom), fixed_cam)
	
func spawn_player():
	player = _player.instance()
	player.position = spawn.position
	player.connect("dead", self, "kill_player")
	call_deferred("add_child", player)
	
func real_tile_size()-> Rect2:
	var longueur:float = (nbr_width * cell_size) 
	var largeur :float  = (longueur / ratio ) 
	return Rect2(0,0, longueur* cut.x, largeur * cut.y)
	
func kill_player():
	player.set_dead(true)
	player.disconnect("dead", self, "kill_player")
	player.queue_free()
	yield(player, "tree_exited")
	spawn_player()
	#base_platform.remove_traps()
	#base_platform.add_traps()


func _on_switch_body_entered(body: Node) -> void:
	$lazer_rotate.emitting = false  
	pass # Replace with function body.
