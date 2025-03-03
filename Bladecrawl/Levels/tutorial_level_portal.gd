extends "res://Levels/Portal_Room.gd"

signal level_transition_available(direction, transition_marker)
signal level_transition_unavailable


func _ready():
	path_open = true

func _transition(_body, direction, transition_marker):
	if path_open:
		level_transition_available.emit(direction, get_node(transition_marker).global_position.x)

func transition_unavailable(_body):
	level_transition_unavailable.emit()

func tutorial_portal_entered(_body):
	if get_parent().has_method("portal_entered"):
		get_parent().portal_entered()
