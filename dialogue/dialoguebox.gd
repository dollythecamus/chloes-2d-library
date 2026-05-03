extends Node2D

@export var choice_scene : PackedScene
@onready var stalk : Polygon2D = $Stalk
@onready var label : RichTextLabel = $Control/Label

signal next
signal chosen(choice)

func _ready() -> void:
	$Control.connect("gui_input", on_gui_input)

func on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			next.emit()

func set_dialogue_position(gp):
	global_position = gp

func show_choices(prompt, choices : Array[DialogueChoice] ):
	show_page(prompt)
	
	for i in range(choices.size()):
		var text = choices[i].choice_text
		var new = choice_scene.instantiate()
		new.hide()
		new.text = text
		new.position.y = new.height * i
		new.set_call(func(): chosen.emit(choices[i]))
		$choices.add_child(new)
	
	for i in $choices.get_children():
		await i.animate_show()

func hide_choices():
	var inv_arr = $choices.get_children()
	# does this invert an array of children nodes? maybe 
	inv_arr.sort_custom(func(a, b): return a.get_index() > b.get_index())
	
	for i in inv_arr:
		await i.animate_hide()
		i.queue_free()

func clear():
	label.text = ""

func show_page(text : String):
	label.visible_ratio = 0.0
	label.text = text
	
	var t = create_tween()
	t.tween_property(label, "visible_ratio", 1.0, .33)
	await t.finished

func animate_show():
	show()
	var t = create_tween()
	scale = Vector2.ZERO
	t.tween_property(self, "scale", Vector2(.2, .8), .16)
	t.chain().tween_property(self, "scale", Vector2.ONE, .16)
	await t.finished

func animate_hide():
	var t = create_tween()
	t.tween_method(set_stalk_point, stalk.polygon[0], Vector2.ZERO, .065)
	t.chain().tween_property(self, "scale", Vector2(.2, .8), .1)
	t.chain().tween_property(self, "scale", Vector2.ZERO, .1)
	await t.finished
	hide()

func point_stalk_to(pos):
	var t = create_tween()
	var vec = pos - global_position
	vec = vec.limit_length(80.0)
	t.tween_method(set_stalk_point, Vector2.ZERO, vec, .2)
	await t.finished

func set_stalk_point(p : Vector2):
	stalk.polygon[0] = p
	stalk.polygon[1] = p + Vector2.ONE * 6
