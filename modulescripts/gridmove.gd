extends Node2D
class_name GridMove

static var grid_size = Vector2i(19, 33) 

@export var to_parent = false
@onready var n : Node2D = get_parent() if to_parent else self

var direction : = Vector2.ZERO
@export var occupy : = true
@export var speed : = 1.0
@export var acceleration : = 1.0
@export var friction : = 1.0

var velocity : = Vector2.ZERO
var last_dir : = Vector2.ONE

@onready var virtual_position : = n.global_position
var grid_position : = Vector2i.ZERO

var is_moving : = false

var enabled : = true :
	set(v):
		set_process(v)

func _ready() -> void:
	self.add_to_group("Grid")

func _process(delta: float) -> void:
	velocity = velocity.move_toward(direction * speed, acceleration * delta) * friction
	virtual_position += velocity * delta
	grid_position = global_to_grid(virtual_position)
	n.global_position = grid_to_global(grid_position)
	
	is_moving = not is_zero_approx(velocity.length())
	if not direction.is_zero_approx():
		last_dir = direction

static func global_to_grid(global_pos):
	@warning_ignore("integer_division")
	return (global_pos as Vector2i / grid_size)

static func grid_to_global(grid_pos):
	return grid_pos * grid_size
