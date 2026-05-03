# from example at godot docs
# https://docs.godotengine.org/en/4.6/tutorials/ui/bbcode_in_richtextlabel.html#custom-bbcode-tags-and-text-effects

@tool
extends RichTextEffect
class_name RichTextJumble

# Syntax: [jumble freq=5.0 span=10.0][/jumble]

# Define the tag name.
var bbcode = "jumble"
@export var noise_x : FastNoiseLite
@export var noise_y : FastNoiseLite

func _process_custom_fx(char_fx : CharFXTransform):
	# Get parameters, or use the provided default value if missing.
	var speed = char_fx.env.get("freq", 5.0)
	var span = char_fx.env.get("span", 10.0)
	
	var t = char_fx.elapsed_time
	var offset = Vector2( 
		sin(t * speed * char_fx.range.x + 
	noise_x.get_noise_2d(t * sin(t), t * sin(t + float(char_fx.glyph_index)))) 
		* span,
		sin(t * speed * char_fx.range.y + 
	noise_y.get_noise_2d(t * sin(t), t * sin(t + float(char_fx.glyph_index)))) 
		* span )
	
	char_fx.offset = offset
	return true
