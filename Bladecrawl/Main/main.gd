extends Node2D



var level
var next_direction: int
var rng = RandomNumberGenerator.new()
var slowdown_scale = 0.4
var slowdown_time = 0.3

@export var map_size = 5
@export var player_packedscene: PackedScene
@export var levelmap: TileMap



func _ready():
	$Player.initiate_companion()
	$CanvasLayer/UI.recieve_player($Player)
	randomize()
	


#generates Dungeon that is the desired size
#L: Left door
#B: bottom door
#R: Right door
#T:top door

#0-99 are reserved for easier enemy rooms
#100-199 are reserved for harder enemy rooms
#200-211 are for LB rooms
#212-223 are for LBR rooms
#224-235 are for BR rooms
#236-247 are for BRT rooms
#248-259 are for RT rooms
#260-271 are for LRT rooms
#272-283 are for LT rooms
#284-295 are for LBT rooms
#296-299 are for L,B,T,R rooms respectively
#300-310 are for Portal rooms

func generate_dungeon():
	$CanvasLayer/Map.on_new_dungeon_entered()
	for y in range(map_size):
		for x in range(map_size):
			
			if x == 0:
				if y == 0:
					level = 224
				elif y == map_size - 1:
					level = 248
				else:
					level = 236
			elif x == map_size - 1:
				if y == 0:
					level = randi_range(200,201)
				elif y == map_size - 1:
					level = 272
				else:
					level = randi_range(284,285)
			else:
				if y == 0:
					level = randi_range(212,215)
				elif y == map_size - 1:
					level = randi_range(260,262)
				else:
					level = randi_range(1,11)
			
			levelmap.set_cell(0,Vector2i(x, y),0,Vector2i(0,0),level)
			
	var portal_cell = Vector2i(randi_range(0, map_size-1),randi_range(0, map_size-1))
	var spawn_cell = Vector2i(randi_range(0, map_size-1),randi_range(0, map_size-1))
	while spawn_cell == portal_cell:
		spawn_cell = Vector2i(randi_range(0, map_size-1),randi_range(0, map_size-1))
	levelmap.set_cell(0,portal_cell, 0, Vector2i(0,0),300)
	levelmap.set_cell(0,spawn_cell, 0, Vector2i(0,0),0)
	levelmap.set_starting_cell(spawn_cell)
	$Player.global_position = Vector2i(1920*spawn_cell.x +960, 1080*spawn_cell.y + 540)
	$Player.initiate_companion()
	$ShakeCamera2D.position_smoothing_enabled = false
	$ShakeCamera2D.position = Vector2i(1920*spawn_cell.x + 960, 1080*spawn_cell.y + 540)
	await get_tree().create_timer(1).timeout
	$ShakeCamera2D.position_smoothing_enabled = true

func level_transition():
	$LevelMap.transitioned()
	$ShakeCamera2D.position = $LevelMap.get_camera_position()
	$Player.transition(next_direction)


func portal_entered():
	levelmap.clear()
	fade_to_black()

func music_loop():
	$MusicPlayer/Loop.play()

func music_outro():
	$MusicPlayer/Loop.stop()
	$MusicPlayer/Outro.play()

func restart():
	get_tree().reload_current_scene()


func hit_slow():
	Engine.time_scale = slowdown_scale
	await get_tree().create_timer(slowdown_time * slowdown_scale).timeout
	Engine.time_scale = 1

func level_transition_available(direction, transition_position):
	next_direction = direction
	$Player.transition_available(transition_position)
	$CanvasLayer/UI.transition_available()

func level_transition_unavailable():
	$Player.transition_unavailable()
	$CanvasLayer/UI.transition_unavailable()


func _on_toggle_map() -> void:
	$CanvasLayer/Map.visible = !$CanvasLayer/Map.visible

func pause():
	$CanvasLayer/PauseMenu.show()
	$CanvasLayer/PauseMenu.is_paused = true
	$Player.paused = true
	Engine.time_scale = 0

func unpause():
	$CanvasLayer/PauseMenu.hide()
	$CanvasLayer/PauseMenu.is_paused = false
	Engine.time_scale = 1
	$Player.paused = false

func fade_to_black():
	$AnimationPlayer.play("FadeToBlack")
	$Player.paused = true

func faded_back_in():
	$Player.paused = false

func add_new_dungeon_score():
	$CanvasLayer/UI.score_update(500)
