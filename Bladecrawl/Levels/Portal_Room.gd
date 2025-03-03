extends "res://Levels/base_level.gd"


func _ready():
	set_doors()
	_open_door()
	_enable_transition()

func _appeared_on_screen():
	room_entered()


func entered_portal(_body):
	if get_parent().get_parent().has_method("portal_entered"):
		get_parent().get_parent().portal_entered()

func set_doors():
	if get_parent() and get_parent().has_method("get_doors"):
		var door_possible:Array = get_parent().get_doors(position)
		var i: int = 0
		var doors:Array = [$DoorRight, $HatchBottom, $DoorLeft, $HatchTop]
		for val in door_possible:
			doors[i].visible = val
			i += 1
