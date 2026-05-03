class_name DialogueEntry
extends Resource

@export var id : String
@export var speaker : String

@export var pages : Array[String]
@export var animations : Array[String]

@export var has_choice : bool = false
@export var choice_prompt : String
@export var choices : Array[DialogueChoice]

@export var next_entry_id : String
