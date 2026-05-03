extends Node
class_name Throwable

@export var mover : Move
@export var pointer : Point
@export var target : Node2D
@export var pickable : Pickable
@export var hurt : Hurt

@onready var n = get_parent()

signal landed

func attack():
	throw()

func throw():
	pickable.set_process(false)
	# spin , go to the player
	pointer.rpm = 10
	pointer.to_point = true
	pointer.aim = false
	
	target.set_process(false) # turn off aim following mouse
	
	hurt.disable()
	
	var d = (target.global_position - n.global_position)
	mover.direction = d.normalized()
	mover.distance = d.length()	
	mover.mag(500)
	pickable.release()
	check_distance_loop()

func check_distance_loop():
	var d = (target.global_position - n.global_position)
	
	if d.length() > 50:
		await get_tree().create_timer(0.1).timeout
		check_distance_loop()
		return
	
	hurt.enable()
	
	pickable.set_process(true)
	mover.direction = Vector2.ZERO
	mover.distance = 1.0
	pointer.to_point = false
	pointer.aim = true
	pointer.rpm = -1
	
	landed.emit()
