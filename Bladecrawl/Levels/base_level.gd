extends Node2D

var path_open: bool = false

@export var has_portal:bool = false

func _get_spawnpoints():
	return $EnemySpawns.get_children()

func _enable_transition():
	path_open = true


func _transition(_body, direction, transition_marker):
	if path_open:
		get_parent().check_neighbor(direction, get_node(transition_marker).global_position.x)

func transition_unavailable(_body):
	get_parent().transition_unavailable()

func _open_door():
	$OpenAnimation.queue("Door_Open")


func _close_door():
	$OpenAnimation.play("Door_Close")

func room_entered():
	if get_parent().has_method("on_new_room_entered"):
		get_parent().on_new_room_entered(has_portal)
