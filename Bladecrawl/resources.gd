extends Node

#enemies
var ghostface = load("res://Enemies/Ranged/ghostface.tscn")
var zombie = load("res://Enemies/Melee/Zombie.tscn")

#scenes
var game_scene = load("res://Main/main.tscn")
var main_menu_scene = load("res://Menus/main_menu.tscn")
var tutorial_scene = load("res://Main/tutorial.tscn")

#stats
var save_file = ConfigFile.new()
var highscore:int = 0

func _ready() -> void:
	var err = save_file.load("user://bladecrawl_save.cfg")
	
	if err != OK:
		print("Couldnt load Scores! Errorcode: ", err)
		return
	
	highscore =  save_file.get_value("Score", "Highscore", 0)

func save_new_highscore() -> void:
	save_file.set_value("Score", "Highscore", highscore)
	save_file.save("user://bladecrawl_save.cfg")
