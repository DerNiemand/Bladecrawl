extends Control

signal close_settings

var master_index = AudioServer.get_bus_index("Master")
var music_index = AudioServer.get_bus_index("Music")
var sfx_index = AudioServer.get_bus_index("SFX")

func _ready():
	$VBoxContainer/MasterVolume.value = db_to_linear(AudioServer.get_bus_volume_db(master_index))
	$VBoxContainer/MusicVolume.value = db_to_linear(AudioServer.get_bus_volume_db(music_index))
	$VBoxContainer/SoundVolume.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_index))

func _on_master_volume_value_changed(value):
	var volume = linear_to_db(value)
	AudioServer.set_bus_volume_db(master_index,volume)


func _on_music_volume_value_changed(value):
	var volume = linear_to_db(value)
	AudioServer.set_bus_volume_db(music_index,volume)


func _on_sound_volume_value_changed(value):
	var volume = linear_to_db(value)
	AudioServer.set_bus_volume_db(sfx_index,volume)


func _on_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$Check.show()
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		$Check.hide()


func _on_texture_button_pressed():
	close_settings.emit()
