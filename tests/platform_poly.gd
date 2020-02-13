extends Polygon2D
var run = false
export (Vector2) var move_to = Vector2.ZERO
export (float) var time_to = 2
export (float) var wait = 0.3

func _ready() -> void:
	$kb/CollisionPolygon2D.polygon = self.polygon
	$kb/Polygon2D.polygon = self.polygon
	$kb/Polygon2D.texture = self.texture
	self.polygon = []

func _process(delta: float) -> void:
	action()
	pass

func action() -> void:
	if run: return
	var end = move_to
	var t = time_to
	run = true
	$tw.interpolate_property($kb, "position", Vector2.ZERO, end, t, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$tw.interpolate_property($kb, "position", end, Vector2.ZERO, t, Tween.TRANS_LINEAR, Tween.EASE_IN, t + wait)
	$tw.start()
	yield($tw, "tween_all_completed")
	yield(get_tree().create_timer(wait), "timeout")
	run = false
