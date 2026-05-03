extends Node2D

var joysticking = false
var has_clicked_with_mouse = false

var speed = 300
@export var target : Node2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not has_clicked_with_mouse:
		has_clicked_with_mouse = true
		joysticking = false
	
	elif event is InputEventMouseMotion and not has_clicked_with_mouse:
		# check if moved enough to detect user
		if event.relative.length() > 5.0:
			has_clicked_with_mouse = true
			joysticking = false
	
	if event is InputEventJoypadMotion:
		if event.axis_value > .1:
			joysticking = true
			has_clicked_with_mouse = false

func _process(delta: float) -> void:
	if target != null:
		aim_at(target)
		return
	
	if joysticking:
		aim_with_joystick(delta)
	
	elif has_clicked_with_mouse:
		aim_to_mouse()

func _on_picked(n: Variant) -> void:
	if n is PlayerControls:
		global_position = n.global_position
		show()

func aim_at(node):
	target = node
	global_position = target.global_position

func aim_with_joystick(delta):
	var v = Input.get_vector("point_left","point_right","point_up", "point_down")
	global_position += v * delta * speed

func aim_to_mouse():
	global_position = get_global_mouse_position()
