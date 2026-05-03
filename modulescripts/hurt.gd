extends Area2D
class_name Hurt

@export var mover : Move
@export var damage := 1
@export var knockback := 90

var in_area = []

func _ready():
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)

func hit_all_area():
	enable()
	collision_mask = 24 # to hurt all
	await get_tree().physics_frame
	await get_tree().create_timer(get_physics_process_delta_time()+.05).timeout
	for i in get_overlapping_areas():
		var d = i.global_position - global_position
		i.hit(damage, knockback, d.normalized())

func _on_area_entered(area: Area2D) -> void:
	if area is Hit:
		in_area.append(area)
		var d = Vector2.ZERO
		if mover != null:
			d = mover.global_velocity.normalized()
		area.hit(damage, knockback, d)

func _on_area_exited(area):
	in_area.erase(area)

func disable():
	Utils.first_child_of_type(self, "CollisionShape2D").disabled = true

func enable():
	Utils.first_child_of_type(self, "CollisionShape2D").disabled = false
