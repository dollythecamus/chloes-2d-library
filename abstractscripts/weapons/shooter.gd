extends Node
class_name Shooter

@export var projectile : PackedScene
@export var pointer : Point
@export var rate : Rate
@export var pickable : Pickable

@export var point : Node2D

@export var fire_rate : = 2.0

var owns

func attack():
	if rate != null:
		if rate.waiting:
			return
		rate.start(fire_rate)
	
	var new = projectile.instantiate()
	var m = new.get_node("Mover")
	new.owns(owns)
	m.direction = Vector2.from_angle(point.global_rotation)
	m.direction += bullet_spread()
	m.mag(1000)
	new.global_position = point.global_position + m.direction
	
	get_tree().current_scene.add_child(new)
	$AudioStreamPlayer.play()

func bullet_spread():
	const a = .1
	return Vector2(
		((randf() - 0.5) * 2),
		((randf() - 0.5) * 2)
	) * a
