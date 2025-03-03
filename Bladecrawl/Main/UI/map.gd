extends Control

signal setup_finished

var setting_up: bool = true

@onready var PlayerWidget = $"MarginContainer/GridContainer/Room0-0/PlayerIcon"

func on_room_entered(room:Vector2i,has_portal):
	if setting_up:
		await setup_finished
	var current_room_widget = get_node("MarginContainer/GridContainer/Room"+str(room.y)+"-"+str(room.x))
	PlayerWidget.reparent(current_room_widget)
	PlayerWidget.set_anchors_preset(Control.PRESET_TOP_LEFT)
	PlayerWidget._set_position(Vector2(100,16))
	if has_portal:
		current_room_widget.color = Color(0,0.682,1,1)
	else:
		current_room_widget.color = Color(0.3,0.3,0.3,1)

func on_new_dungeon_entered():
	setting_up = true
	for x in 5:
		for y in 5:
			get_node("MarginContainer/GridContainer/Room"+str(y)+"-"+str(x)).color = Color(0.1,0.1,0.1,1)
	setting_up = false 
	setup_finished.emit()

func _unhandled_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("Menu"):
			get_viewport().set_input_as_handled()
			visible = false
