extends Node
class_name Move


@export_group("Connections")
@onready var n = get_parent()
@export var inertia : Node2D
@export var constraint : Node

@export_group("Rates")
@export var direction : = Vector2.ZERO
@export var speed : = 1.0
@export var acceleration : = 1.0
@export var friction : = 1.0
@export var distance : = 1.0

var velocity = Vector2.ZERO
var global_velocity = Vector2.ZERO

var last = Vector2.ZERO

func _ready() -> void:
	if inertia == null:
		inertia = n

func _process(delta: float) -> void:
	global_velocity = velocity + (inertia.global_position - last)
	
	if constraint != null:
		direction = constraint.constrain(direction)
	
	velocity = velocity.move_toward(direction * speed, acceleration * distance * delta) * friction
	n.position += velocity * delta
	
	last = inertia.global_position

func mag(x):
	velocity = direction * x

func enable():
	set_process(true)

func disable():
	set_process(false)
	
