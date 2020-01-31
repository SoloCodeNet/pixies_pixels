tool
extends Area2D

export(bool) var enabled := true
export(String, "Attract", "Repulse") var mode := "Attract"
export(String, "Horizontal", "Vertical", "Both") var axe := "Horizontal"
export(int, 0, 1000) var mass := 300
export(int, -1000, 1000) var min_force := -300
export(int, -1000, 1000) var max_force := 300

onready var pos = $Position2D
var bodies := []

func _ready() -> void:
	set_physics_process(false)

	
func set_axe(value: String):
	axe = value

func attract(body: KinematicBody2D) -> Vector2:
	var force: Vector2 = $Position2D.position - body.position  
	var lenght = force.length() if force.length() > 1 else 1
	var direction = 1 if mode == "Repulse" else -1
	
	var strength = direction * mass * body.mass / lenght * lenght
	print(strength)
	strength = clamp(strength, min_force, max_force)
	force =  force.normalized() * strength
	
	if body.is_on_floor() and force.y > 0:
		force.y = 0
	
	if axe == "Horizontal":
		force.y = 0
	elif axe == "Vertical":
		force.x = 0

	return force
	
func _physics_process(delta: float) -> void:
	for body in bodies:
		if body.has_method("apply_force"):
			body.is_force_applied = true
			body.apply_force(attract(body))


func _on_Force_body_entered(body: Node) -> void:
	print("Force - body entered")
	if enabled:
		if body.has_method("apply_force"):
			bodies.append(body)
			set_physics_process(true)


func _on_Force_body_exited(body: Node) -> void:
	if enabled:
		if body.has_method("apply_force"):
			body.is_force_applied = true
			bodies.erase(body)
		if bodies.size() == 0:
			set_physics_process(false)
