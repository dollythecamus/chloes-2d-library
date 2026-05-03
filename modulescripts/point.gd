extends Node2D
class_name Point

@export var rotate_parent = false
@onready var n = get_parent() if rotate_parent else self

@export_group("Behavior")
@export var pointing = false
@export var aim = false
@export var to_reset = false
@export var flips_at_half = false
@export var target : Node2D
@export var mover_inertia : Move
@export_group("Rates")
@export var random = -1
@export var rpm = -1
@export var angle_offset := PI/2
@export_group("Range")
@export var angle_max = PI/16
@export var angle_min = -PI/16
@export var angle_step = PI/15
@export_group("Periodic")
@export var frequency : float = -1

var target_angle = 0.0
var clock = 0.0

var last = Vector2.ZERO
var vec = Vector2.ZERO

var has_clicked_with_mouse = false
var joysticking = true

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
	# the pickup area circles the parent node (player) in the direction of the mouse
	if not pointing:
		if to_reset:
			n.rotation = 0.0 
		return
	
	if target != null:
		point_to_target()
	elif aim:
		if joysticking:
			point_to_aim()
		
		elif has_clicked_with_mouse:
			point_to_mouse()
	
	elif rpm != -1:
		spin(delta)
	
	elif mover_inertia != null:
		point_to(n, mover_inertia.direction.angle())
	
	elif frequency != -1:
		var t = sin(clock * frequency) * .5 + .5
		clock += delta
		target_angle = lerp(angle_min, angle_max, t)
		n.rotation = snapped(target_angle, angle_step)
	
	if (n.rotation_degrees > 90 || n.rotation_degrees < -90) and flips_at_half:
		n.scale.y = -1
	else:
		n.scale.y = 1

func point_to_aim():
	vec = Input.get_vector("point_left","point_right","point_up", "point_down")
	
	if vec.length() > 0:
		point_to(n, vec.angle())

func point_to_target():
	point_to(n, (target.global_position - n.global_position).angle())

func point_to_mouse():
	vec = get_global_mouse_position() - global_position
	
	if vec.length() > 0:
		point_to(n, vec.angle())

func point_to(node, angle):
	node.global_rotation = angle + angle_offset

func move_angle(angle):
	angle_offset = move_toward(angle_offset, angle_offset + angle, PI/32)

func spin(delta):
	clock += delta * rpm
	point_to(n, Vector2(cos(clock), sin(clock)).angle())
