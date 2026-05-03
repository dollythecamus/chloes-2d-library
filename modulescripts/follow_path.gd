extends Node

@onready var n = get_parent()

@export var current_node : PathNode

func _process(_delta: float) -> void:
	try_switch_node()

func constrain(direction):
	return current_node.movement_modifier(n.position, direction)

func try_switch_node():
	var dist = n.position.distance_to(current_node.position)
	for i in current_node.connections:
		var node = current_node.get_path_node(i)
		var n_dist = n.position.distance_to(node.position)
		if n_dist < dist:
			current_node.is_current = false
			current_node = node
			current_node.is_current = true
			break
