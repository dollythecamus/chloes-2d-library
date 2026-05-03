@tool
extends Node2D
class_name PathNode

static var debug = false

@export var debug_font : Font

@export_tool_button("Connect Selected") var btn_conn: Callable = connect_selected
@export var draw_field = false:
	set(v):
		draw_field = v
		# set all siblings to also draw the fields 
		#get_siblings().all(func(x): if x.draw_field != v: x.draw_field = v)

@export var mm_debug = false:
	set(v):
		mm_debug = v
		# set all siblings to also draw the fields 
		#get_siblings().all(func(x): if x.draw_field != v: x.draw_field = v)

var is_current = false

@export var index = 0
@export var max_index = 0:
	get():
		return get_siblings().size()-1

@export var connections : = []
@export var radius = 20.0

@export var frozen = false:
	set(v):
		frozen = v
		get_siblings().all(func(x): if x.frozen != v: x.frozen = v)

var df_c = 0.0

func _enter_tree() -> void:
	if frozen:
		return
	if Engine.is_editor_hint():
		# get the index properly
		var i = 0
		for j in get_siblings():
			if j == self:
				index = i
			i += 1

func _draw() -> void:
	if not (Engine.is_editor_hint() or debug):
		return
		
	if is_current:
		draw_circle(Vector2.ZERO, radius + 5.0, Color.BLUE_VIOLET)
	
	draw_circle(Vector2.ZERO, radius, Color.DARK_RED, false)
	for i in connections:
		var node = get_path_node(i)
		var line = node.position - position
		draw_line(Vector2.ZERO, line, Color.YELLOW_GREEN)
	
	if mm_debug:
		draw_movement_modifier_debug(get_global_mouse_position())
	
	if draw_field:
		draw_field_around_position(get_global_mouse_position())

func draw_movement_modifier_debug(pos):
	var k = 0
	
	var result_dir = Vector2.ZERO
	#var z = Vector2.ZERO
	
	for i in connections:
		var node = get_path_node(i)
		if node == self:
			push_error("weird connection to itself, stop it, index: " + str(index) )
			return
		
		var A = position
		var B = node.position
		var P = pos
		
		var AB = B - A
		var AP = P - A
		
		var t = AP.dot(AB) / AB.dot(AB)
		t = clamp(t, 0.0, 1.0)
		var closest = A + t * AB
		var distance = P.distance_to(closest)
		var PC = closest - P
		
		var taper_radius = lerp(radius, node.radius, t)
		var p_effective_radius = taper_radius
		
		var weight = 1.0 - inverse_lerp(0, radius, distance)
		if distance > p_effective_radius:
			weight = 0
		
		var p = pos - position
		
		draw_circle(closest - position, 4.0, Color.GREEN_YELLOW)
		draw_line(closest - position, p, Color.SEA_GREEN)
		
		draw_string(debug_font, p + Vector2.DOWN * k * 30, "distance: " + str(distance))
		draw_string(debug_font, p + Vector2.DOWN * 16 + Vector2.DOWN * k * 30, "weight: " + str(weight))
		
		var match_dir = Vector2.ZERO
		
		for L in range(1, 5):
			
			var angle_slices = 2 * PI / 4
			var slice = L * angle_slices
			var dir = Vector2.RIGHT.rotated(slice)
			
			#draw_line(p + dir * 5, p + dir * 20, Color.INDIAN_RED)
			
			match_dir = match_direction(dir.normalized(), PC.normalized()) * (1.0 - weight)
			
			#draw_line(p + (dir * 5) + (dir.rotated(PI*.5) * 3), p + match_dir * 20, Color.PURPLE)
			
			result_dir = match_quadrant2D(AB, dir) * weight + match_dir
			result_dir = result_dir.lerp(dir.normalized(), weight)
			
			draw_line(p, p + result_dir, Color.AQUA)
			
		k += 1
	
	draw_line(pos-position, pos-position+(result_dir*15).limit_length(100), Color.AQUAMARINE)

# this works, is it helpful? no, but i had fun writing this silly code, bye
func draw_field_around_position(pos):
	var d = 4
	var d2 = 5
	var res = Vector2i(7, 3)
	for i in range(res.x):
		for j in range(1, res.y):
			var angle_slices = 2 * PI / res.x
			var slice = i * angle_slices
			var slice_dir = Vector2.RIGHT.rotated(slice)
			
			for k in range(res.x): # more directions, waow
				var sub_as = 2 * PI / res.x
				var sub_s = k * sub_as
				var sub_sd = Vector2.RIGHT.rotated(sub_s)
				
				var p = pos + (slice_dir * d2 * j) + (sub_sd * 2)
				var result = movement_modifier(p, sub_sd) * d
				
				var start = p - position
				var end = p + result - position
				
				#draw_circle(start, .3, Color.NAVY_BLUE)
				draw_line(start, end, Color.BLUE_VIOLET, .3)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or debug:
		queue_redraw()
	else:
		return

func connect_selected():
	if frozen:
		return
	
	var sel = EditorInterface.get_selection().get_selected_nodes()
	for node in sel:
		if node is PathNode:
			if node == self:
				continue
			connections.append(node.index)
			node.connections.append(index)

func movement_modifier(pos : Vector2, dir : Vector2) -> Vector2:
	if (dir.is_zero_approx()):
		return Vector2.ZERO
	
	var result_dir = Vector2.ZERO
	var args = {'AB':Vector2.ZERO, 'PC':Vector2.ZERO, 'distance':9999.0, 'weight':0.0, 'taper_radius':0.0}
	
	for i in connections:
		var node = get_path_node(i)
		if i == index:
			push_error("weird connection to itself, stop it, index: " + str(index) )
			return dir
		
		var A = position
		var B = node.position
		var P = pos
		
		var AB = B - A
		var AP = P - A
		
		var t = AP.dot(AB) / AB.dot(AB)
		t = clamp(t, 0.0, 1.0)
		var closest = A + t * AB
		var distance = P.distance_to(closest)
		var PC = closest - P
		# minimum distance
		if distance < args.distance:
			args.distance = distance
			args.AB = AB
			args.PC = PC
	
	args.weight = clampf(1.0 - inverse_lerp(0, radius, args.distance), 0.0, 1.0)
	var match_dir = match_direction(dir.normalized(), args.PC.normalized()) * (1.0 - args.weight)
	result_dir = (match_quadrant2D(args.AB, dir) * args.weight) + match_dir
	result_dir = result_dir.slerp(dir.normalized(), args.weight)
	
	return result_dir.limit_length(1.0)

func get_path_node(i):
	for j in get_siblings():
		if j.index == i:
			return j
	return null

func get_siblings():
	if not is_node_ready():
		return []
	return get_parent().get_children()

func match_direction(a, b):
	var an = a.normalized()
	var bn = b.normalized()
	
	var dot = an.dot(bn)
	var t = inverse_lerp(-1.0, 1.0, dot)
	return bn * t

func match_quadrant2D(a, b):
	return Vector2(abs(a.x) * signf(b.x), abs(a.y) * signf(b.y))
