extends Area2D

@onready var n = get_parent()

@export var setter : = {
	"z_index": 0
}

var hidden_color = Color(1.0, 1.0, 1.0, 0.0)
var shown_color = Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)
	
	check_area()

func _on_area_entered(_area):
	animate_show()
	show_all_inside(get_overlapping_areas())
	set_variables(_area.get_parent())

func _on_area_exited(_area):
	animate_hide()
	hide_all_inside(get_overlapping_areas())

func animate_hide():
	var t = create_tween()
	t.tween_property(n, "modulate", hidden_color, .5)
	await t.finished

func animate_show():
	var t = create_tween()
	t.tween_property(n, "modulate", shown_color, .5)
	await t.finished

func show_all_inside(areas):
	for i in areas:
		i.get_parent().show()

func hide_all_inside(areas):
	for i in areas:
		i.get_parent().hide()

func set_variables(character : Node):
	for k in setter.keys():
		var value = setter[k]
		character.set(k, value)

func check_area():
	var arr = get_overlapping_areas()
	if not arr.is_empty():
		animate_show()
	else:
		animate_hide()
