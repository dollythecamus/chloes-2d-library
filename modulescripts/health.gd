extends Node
class_name Health

@onready var n = get_parent()

signal health_changed(v)

@export var is_player = false

const dmg_boost_def = .7
var damage_boost = false
var damage_boost_time = .7

@export var health = 10:
	set(v):
		if health < v:
			health = v
			health_changed.emit(v)
		
		if damage_boost:
			return
		
		if health > v:
			c = 0
			health = v
			damage_boost = true
			health_changed.emit(v)
		
		if health <= 0:
			n.die()
			if not is_player:
				pass

var c = 0
func _process(delta):
	c += delta
	if damage_boost and c >= damage_boost_time:
		damage_boost = false
		damage_boost_time = dmg_boost_def # change time it back after invul
		c = 0

func invul(time):
	c = 0
	damage_boost = true
	damage_boost_time = time
