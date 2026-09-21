extends Node2D
class_name GridMove

@export var to_parent = true
@onready var n : Node2D = get_parent() if to_parent else self

const grid_size = Vector2i(25, 25) * 4 # temporary scale factor
static var width  = 20
static var height = 20

static var occupied_grid = {}
static var at_layer = {}

@export var occupy : = true
@export var slip : = true
@export var free_grid : = false

@export var occupied_grid_layer : int

@export var speed : = 1.0
@export var acceleration : = 1.0
@export var friction : = 1.0

var direction : = Vector2.ZERO
var velocity : = Vector2.ZERO
var last_dir : = Vector2.ONE

var grid_position : = Vector2i.ZERO:
	set(value):
		set_occupied(false, grid_position)
		grid_position = value
		set_occupied(occupy, grid_position)
@onready var virtual_position : = n.global_position

var is_moving : = false

var enabled : = true:
	set(v):
		set_process(v)

func _ready() -> void:
	grid_position = global_to_grid(virtual_position)
	create_grid()
	
	await get_tree().create_timer(0.1).timeout
	add_self()
	set_to_grid()

func _exit_tree() -> void:
	set_occupied(false)
	at_layer[occupied_grid_layer].erase(self)

func _process(delta: float) -> void:
	velocity = velocity.move_toward(direction * speed, acceleration * delta) * friction
	virtual_position += velocity * delta
	set_to_grid()
	
	is_moving = not is_zero_approx(velocity.length())
	if not direction.is_zero_approx():
		last_dir = direction

func add_self():
	at_layer[occupied_grid_layer].append(self)

# grid !
func create_grid(reset = false):
	if at_layer.has(occupied_grid_layer) and not reset:
		# do it once and then never
		return
	if occupied_grid.has(occupied_grid_layer) and not reset:
		# do it once and then never
		return
	
	at_layer[occupied_grid_layer] = []
	occupied_grid[occupied_grid_layer] = []
	for x in width:
		occupied_grid[occupied_grid_layer].append([])
	
	for y in height:
		for x in width:
			occupied_grid[occupied_grid_layer][x].append(false)

func set_occupied(occ : bool, gp = grid_position):
	if occupied_grid.is_empty() or not occupied_grid.has(occupied_grid_layer):
		return
	
	if gp.x < 0 or gp.y < 0:
		return
	if gp.x >= width or gp.y >= height:
		return
	occupied_grid[occupied_grid_layer][gp.x][gp.y] = occ

func try_move_to(dir : Vector2i):
	var gp = grid_position + dir
	
	if is_occupied(gp):
		return

	grid_position = gp
	virtual_position = grid_to_global(grid_position)
	n.global_position = virtual_position

func cardinal(dir : Vector2) -> Vector2i:
	if abs(dir.x) > (abs(dir.y)):
		return Vector2i(sign(dir.x), 0)
	else:
		return Vector2i(0, sign(dir.y))

# okays
func is_occupied(gp = grid_position, layer_ = occupied_grid_layer):
	if gp.x < 0 or gp.y < 0:
		return false
	if gp.x >= width or gp.y >= height:
		return false
	return occupied_grid[layer_][gp.x][gp.y]

func set_to_grid():
	var gp = global_to_grid(virtual_position)
	
	if occupy and is_occupied(gp):
			# the grid it wants to go is occupied.
			# two things can't be in the same place
			# so chill out, sit down
			virtual_position = n.global_position
			return
	
	grid_position = gp
	
	if free_grid:
		n.global_position = virtual_position
	else:
		n.global_position = grid_to_global(grid_position)

func get_at_grid(gp = grid_position, layer_ = occupied_grid_layer):
	for i in at_layer[layer_]:
		if i.grid_position == gp:
			return i
	return null

func remove_duplicates(to_free = false):
	var seen = []
	var dupes = []
	for obj in at_layer[occupied_grid_layer]:
		if seen.has(obj.grid_position):
			dupes.append(obj)
		else:
			seen.append(obj.grid_position)
	
	if to_free:
		for i in dupes:
			i.n.queue_free()

static func global_to_grid(global_pos):
	@warning_ignore("integer_division")
	return (global_pos as Vector2i / grid_size)

static func grid_to_global(grid_pos):
	return grid_pos * grid_size
