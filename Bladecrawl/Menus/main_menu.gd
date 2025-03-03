extends Node2D

func _on_play_pressed():
	get_tree().call_deferred("change_scene_to_packed",Resources.tutorial_scene)


func _on_exit_pressed():
	get_tree().quit()


func _on_settings_pressed():
	$CanvasLayer/MainMenuInterface.hide()
	$CanvasLayer/SettingsMenu.show()

func close_Settings():
	$CanvasLayer/MainMenuInterface.show()
	$CanvasLayer/SettingsMenu.hide()
