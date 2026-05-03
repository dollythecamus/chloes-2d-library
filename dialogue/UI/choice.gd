extends Node2D

var height = 52
var text : String:
	set(v):
		text = v
		$Label.text = text

func set_call(to_call):
	$Button.connect("pressed", to_call)

func animate_show():
	show()
	var t = create_tween()
	scale = Vector2.ZERO
	$Label.visible_ratio = 0.0
	t.tween_property(self, "scale", Vector2(.2, .8), .16)
	t.chain().tween_property(self, "scale", Vector2.ONE, .16)
	t.parallel().tween_property($Label, "visible_ratio", 1.0, .2)
	await t.finished

func animate_hide():
	var t = create_tween()
	t.tween_property($Label, "visible_ratio", 0.0, .2)
	t.parallel().tween_property(self, "scale", Vector2(.2, .8), .1)
	t.chain().tween_property(self, "scale", Vector2.ZERO, .1)
	await t.finished
	hide()
