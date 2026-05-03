extends Node2D
class_name Rate

@export var clock_display : DISPLAY
@export var color : Color = Color.DARK_CYAN
@export var radius = 10

enum DISPLAY {circle, line}

signal done
var waiting

var c = 0
var duration = TAU
var interupted = false

func _ready() -> void:
	set_process(false)

func start(rate):
	c = 0
	duration = rate
	waiting = true
	show()
	set_process(true)
	await get_tree().create_timer(rate).timeout
	if interupted:
		return
	done.emit()
	waiting = false
	hide()
	set_process(false)

func interrupt():
	waiting = false
	hide()
	set_process(false)

func _process(delta: float) -> void:
	c += delta
	queue_redraw()

func _draw() -> void:
	match clock_display:
		DISPLAY.circle:
			draw_clock_circle()
		DISPLAY.line:
			draw_clock_line()

func draw_clock_circle():
	var res = 32
	var inc = TAU / res
	var p1 = Vector2.RIGHT * radius
	for i in res:
		var j = inc * i
		var _i = (j / TAU) < (c / duration)
		if _i:
			var next = Vector2.from_angle(j) * radius
			var p2 = next - p1
			draw_line(p1, p1 + p2, color, 4.0)
			p1 += p2
		else:
			break

func draw_clock_line():
	var p1 = -position
	var p2 = Vector2.ZERO
	var weight = c/duration
	draw_line(p1, lerp(p1, p2, weight), color, 5.0)
