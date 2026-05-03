extends Area2D
class_name Pickup

@onready var n := get_parent()

var did_pick = false
var node_picked = null
@export var is_player = false

func release(other = false):
	if node_picked != null:
		did_pick = false
		node_picked.get_node("Pickable").disconnect("released", _on_released)
		if not other:
			node_picked.get_node("Pickable").release()
		node_picked = null

func pick_first(owns):
	var a = get_overlapping_areas()
	if a.size() > 0:
		if a[0] is Pickable:
			pick(a[0], owns)
			return true

func pick(area, owns = n):
	if not area.is_picked:
		area.pick(n)
		area.owns(owns)
		area.connect("released", _on_released)
		node_picked = area.get_parent()
		did_pick = true
	else:
		release()

func _on_released():
	release(true)

func _on_area_entered(area: Area2D) -> void:
	if area is Pickable:
		n.expect.emit(PlayerControls.Actions.GRAB)
