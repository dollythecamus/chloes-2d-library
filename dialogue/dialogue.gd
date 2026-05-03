extends Node2D

@onready var box = $DialogueBox

@export var test : DialogueData

var current_dialogue
var current_entry
var current_page

var wait_choice = false
var wait_next = false
var wait_response = false
var queued_entry = ""

func _ready() -> void:
	box.connect("next", on_next)
	box.connect("chosen", on_choice)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		start_dialogue(test, "bwa")

func start_dialogue(data, id):
	current_dialogue = data
	current_entry = find_entry(id)
	current_page = 0
	
	var character = get_character(current_entry.speaker)
	box.set_dialogue_position(character.dialogue_point.global_position)
	await box.animate_show()
	await play_current_entry()

func play_current_entry():
	if current_entry == null:
		end_dialogue()
		return
	
	wait_choice = false
	wait_next = true
	
	var character = get_character(current_entry.speaker)
	box.set_dialogue_position(character.dialogue_point.global_position)
	await box.point_stalk_to(character.speaker_point.global_position)
	cue_character_animation()
	await show_current_page()

func show_current_page():
	if current_page >= current_entry.pages.size():
		end_page_sequence()
		return
	
	await box.show_page(current_entry.pages[current_page])

func cue_character_animation():
	pass

func end_dialogue():
	current_dialogue = null
	current_entry = null
	current_page = 0
	wait_choice = false
	wait_next = false
	
	await box.animate_hide()

func end_page_sequence():
	wait_next = false
	if current_entry.has_choice and not current_entry.choices.is_empty():
		wait_choice = true
		await box.show_choices(current_entry.choice_prompt, current_entry.choices)
		return
	
	next_entry(current_entry.next_entry_id)
	
	return
	
	if wait_response:
		next_entry(queued_entry)
		wait_response = false
		queued_entry = ""
		return

func get_character(n : String):
	return get_tree().current_scene.find_child(n, true)

func find_entry(id):
	var a = current_dialogue.entries.filter(func(x): return x.id == id)
	if not a.is_empty():
		return a[0]
	return null

func next_entry(id):
	current_entry = find_entry(id)
	current_page = 0
	box.clear()
	
	
	if current_entry == null:
		end_dialogue()
		return
	
	play_current_entry()

func on_next():
	if !wait_next:
		return
	
	current_page += 1
	
	if current_page < current_entry.pages.size():
		show_current_page()
		return
	
	end_page_sequence()

func on_choice(choice):
	wait_choice = false
	await box.hide_choices()
	handle_player_choice(choice)
	#queued_entry = choice.next_entry_id
	# next_entry(choice.next_entry_id)

func handle_player_choice(choice):
	#wait_response = true
	next_entry(choice.response_id)
