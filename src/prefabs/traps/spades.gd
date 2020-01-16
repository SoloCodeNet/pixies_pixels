extends Node2D

func _ready()-> void:
	$spade_area.connect("body_entered", self, "_on_spade_area_body_entered")

func _on_spade_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.emit_signal("dead")

