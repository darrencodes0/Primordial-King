extends Node2D

class_name TurnQueue

var active_char : Character
var prev_char : Character
@onready var camera_transition = $"../CameraTransition"

func _ready():
	var characters = get_children()
	active_char = get_child(0)
	for i in characters.size():
		characters[i].turn_complete.connect(_play_turn)

func _play_turn():
	var new_index = (active_char.get_index() + 1) % get_child_count()
	prev_char = active_char
	active_char = get_child(new_index)
	camera_transition.transition_camera(prev_char.find_child("CharacterCamera"), active_char.find_child("CharacterCamera"))
