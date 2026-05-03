@tool
extends Node2D
class_name AnimatedFrames

@onready var frames = get_children()
@export var looping = false
@export var auto_start = false
@export var reverse = false

@export var fpf = 6 # frames of `process delta time per rendered frame
var f = 0

var l = -1
var i = 0

signal finished
signal framed

func _ready() -> void:
	get_children().all(func(x): x.hide())
	
	set_process(false)
	
	if auto_start:
		play()

func play():
	i = 0
	l = -1 if not reverse else 1
	f = 0
	get_node("frame" + str(i)).show() # show first frame
	framed.emit() # first frame
	set_process(true)

func stop():
	finished.emit()
	set_process(false)

func next_frame():
	var inc = -1 if reverse else 1
	i += inc
	l += inc
	if looping:
		i = wrapi(i, 0, get_child_count())
		l = wrapi(l, 0, get_child_count())
	safe_hide(l) # hide last frame
	safe_show(i) # show current frame
	framed.emit()

# safe functions that won't throw exceptions if the index is out of bounds
func safe_hide(index):
	var n = get_node_or_null("frame" + str(index))
	if n != null:
		n.hide()

func safe_show(index):
	var n = get_node_or_null("frame" + str(index))
	if n != null:
		n.show()

func _process(_delta: float) -> void:
	f += 1
	if f >= fpf:
		if i >= get_child_count() and not looping:
			stop()
			return
		next_frame()
		f = 0
