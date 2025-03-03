extends "res://Main/main.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.initiate_companion()
	$CanvasLayer/UI.recieve_player($Player)
	$CanvasLayer/UI/Score.visible = false

func level_transition():
	if next_direction == 0:
		$ShakeCamera2D.position.x += 1920
	elif next_direction == 8:
		$ShakeCamera2D.position.x -= 1920
	$Player.transition(next_direction)

func portal_entered():
	get_tree().call_deferred("change_scene_to_packed",Resources.game_scene)

