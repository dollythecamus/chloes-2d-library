# from example at godot docs
# https://docs.godotengine.org/en/4.6/tutorials/ui/bbcode_in_richtextlabel.html#custom-bbcode-tags-and-text-effects

@tool
extends RichTextEffect
class_name RichTextModify

# Syntax: [mod][/mod]

# this modifier RTE is used to offset the 2d position of char_fx by some programmed value
# using modifyRTE script

# Define the tag name.
var bbcode = "mod"
@export var mod_name := ""
@export var modifiers = [
		{"name":"face", "offset":Vector2.ONE},   # id = 0
	]

func _process_custom_fx(char_fx : CharFXTransform):
	# Get parameters, or use the provided default value if missing.
	var id = char_fx.env.get("id", 0)
	if modifiers[id].has("offset"):
		char_fx.offset = modifiers[id]["offset"]
	return true
