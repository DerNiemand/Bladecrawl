extends "res://Levels/base_level.gd"

signal level_transition_available(direction, transition_marker)
signal level_transition_unavailable


func _ready():
	path_open = true
	_open_door()

func _transition(_body, direction, transition_marker):
	if path_open:
		level_transition_available.emit(direction, get_node(transition_marker).global_position.x)

func transition_unavailable(_body):
	level_transition_unavailable.emit()
