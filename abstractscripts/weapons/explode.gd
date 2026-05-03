extends Node

@export var effect : AnimatedFrames
@export var hurt : Hurt
@export var rate : Rate
@export var visual : Node2D

@onready var n = get_parent()

func explode():
	rate.start(.5)
	
	await rate.done
	
	$AudioStreamPlayer.play()
	visual.hide()
	effect.show()
	effect.play()
	await hurt.hit_all_area()
	hurt.disable()
	
	await effect.finished
	await $AudioStreamPlayer.finished
	
	n.queue_free()
