extends Control

signal resume
signal pause

var is_in_settings: bool = false
var is_paused: bool = false

func _on_resume_pressed():
	resume.emit()

func _on_main_menu_pressed():
	Engine.time_scale = 1
	get_tree().change_scene_to_packed(Resources.main_menu_scene)

func _on_exit_pressed():
	get_tree().quit()


func _on_settings_pressed():
	$PauseInterface.hide()
	$SettingsMenu.show()
	is_in_settings = true

func close_settings():
	$PauseInterface.show()
	$SettingsMenu.hide()
	is_in_settings = false

func _unhandled_input(event):
	if event.is_action_pressed("Menu"):
		if is_in_settings:
			close_settings()
		elif is_paused:
			resume.emit()
		else:
			pause.emit()
