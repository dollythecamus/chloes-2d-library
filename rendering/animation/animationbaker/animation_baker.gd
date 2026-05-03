extends Node

@onready var animation = $Animation
@onready var viewport = $SubViewport

@export_dir var save_path 
@export var animated : AnimatedFrames
@export var resolution = Vector2(256, 256)
@export var transparent_bg = true

var baking_animated

# slowed down the frame rate of rendering. 
# still fast but ensures that it actually gets baked 
# without skipping or duplicate frames
const baking_fpf = 8

var finished = false
var textures = []

func _ready() -> void:
	viewport.size = resolution
	viewport.transparent_bg = transparent_bg

func _process(_delta: float) -> void:
	bake()
	set_process(false)

func bake():
	duplicate_animation()
	animated.play()
	frame_loop()
	await animated.finished
	save_spritesheet(processing())
	save_spriteframes_res()

func frame_loop():
	await animated.framed
	print("framed")
	
	textures.append(viewport.get_texture().get_image())
	
	await RenderingServer.frame_post_draw
	print("post draw")
	
	if finished:
		return
	
	await frame_loop()

func _on_finished():
	finished = true

func processing() -> Image:
	print("processing")
	var size = viewport.size
	var x_size = size.x * textures.size()
	var image = Image.create_empty(x_size, size.y, false, Image.FORMAT_RGBA8)
	for i in range(textures.size()):
		image = combine_spritesheet(image, textures[i], Vector2i(size.x * i, 0))
	return image

func combine_spritesheet(base : Image, image : Image, position : Vector2i):
	for y in image.get_height():
		for x in image.get_width():
			base.set_pixelv(Vector2i(position.x + x, position.y + y), image.get_pixelv(Vector2i(x ,y)))
	return base

func save_spritesheet(image : Image):
	print("saved image")
	image.save_png(save_path + "/" + animated.name + ".png")

func save_spriteframes_res():
	var spriteframes = SpriteFrames.new()
	spriteframes.add_animation(animated.name)
	for i in textures:
		var texture = ImageTexture.create_from_image(i)
		spriteframes.add_frame(animated.name, texture)
	ResourceSaver.save(spriteframes, save_path + "/" + animated.name + ".res")

func duplicate_animation():
	remove_child(animation)
	viewport.add_child(animation)
	animated.finished.connect(_on_finished)
	animated.fpf = baking_fpf
