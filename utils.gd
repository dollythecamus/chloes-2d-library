extends Node
class_name Utils

static func add_module_script(node, script, callable):
	var new = Node.new()
	new.set_script(load("res://Scripts/" + script))
	node.add_child.call_deferred(new)
	callable.call(new)
	return new

static func first_child_of_type(node, type):
	for i in node.get_children():
		if i.is_class(type):
			return i
