extends Area2D
class_name Hit

@export var flash : Node2D
@export var health : Health
@export var mover : Move

@onready var c = Utils.first_child_of_type(self, "CollisionShape2D")

signal HIT

var flashed = false:
	set(v):
		if v:
			flashed = true
			flash.visible = true
			await get_tree().create_timer(.1).timeout
			flashed = false
			flash.visible = false

func hit(dmg, knock, dir):
	flashed = true
	health.health -= dmg
	if mover != null:
		mover.velocity += dir * dmg * knock
	HIT.emit()
	$AudioStreamPlayer.play()

func disable():
	c.disabled = true

func enable():
	c.disabled = false
