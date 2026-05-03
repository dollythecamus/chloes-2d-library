extends Node
class_name ModifyRTE

@export var rich_text : RichTextLabel
@export var mod_name := ""
@onready var mod : RichTextModify = get_mod(rich_text.custom_effects)
@onready var name_id_lookup = name_id(mod.modifiers)

func get_mod(effects : Array) -> RichTextModify:
	return effects.get(effects.find_custom(func(x): return mod_name == x.mod_name))

func name_id(modifiers : Array) -> Dictionary:
	var res = {}
	for i in range(modifiers.size()):
		var m = modifiers[i]
		res[m["name"]] = i
	return res

func set_modifier(id, key, value):
	mod.modifiers[id].set(key, value)

func set_modifier_by_name(_name, key, value):
	# instead of searching for the right name every time, 
		# just use the look up table. obv
	set_modifier(name_id_lookup[_name], key, value)
