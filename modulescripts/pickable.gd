extends Area2D
class_name Pickable

@export var move : Move
@export var point : Point
@export var hurt : Hurt
@export var shooter : Shooter

@onready var n := get_parent()
var target
var is_picked = false

signal picked(n)
signal released

const player_hit = 8
const enemy_hit = 16

func release():
	target = null
	is_picked = false
	point.to_point = is_picked
	released.emit()
	owns(null)

func pick(node):
	target = node
	is_picked = true
	point.to_point = is_picked
	picked.emit(node)

func owns(_n):
	if _n is PlayerControls:
		if hurt != null:
			hurt.collision_mask = enemy_hit # to hurt bots only
		point.aim = true
		point.target = null
	elif _n is Enemy:
		if hurt != null:
			hurt.collision_mask = player_hit # to hurt players only
		point.target = _n.target
	elif _n == null:
		if hurt != null:
			hurt.collision_mask = 0 # to hurt none
		point.target = null
	
	if shooter != null:
		shooter.owns = _n

func _process(_delta: float) -> void:
	move_to_target()

func move_to_target():
	if target == null:
		move.direction = Vector2.ZERO
		move.distance = 0
		return
	
	move.direction = target.global_position - n.global_position
	move.distance = n.global_position.distance_to(target.global_position)
