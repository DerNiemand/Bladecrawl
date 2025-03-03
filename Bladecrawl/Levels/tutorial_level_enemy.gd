extends "res://Levels/level_enemy.gd"

signal level_transition_available(direction, transition_marker)
signal level_transition_unavailable

func _transition(_body, direction, transition_marker):
	if path_open:
		level_transition_available.emit(direction,get_node(transition_marker).global_position.x)

func transition_unavailable(_body):
	level_transition_unavailable.emit()

func _enemy_spawn():
	enemy_rng.randomize()
	
	spawnpoints = _get_spawnpoints()
	spawnpoints.append_array(spawnpoints)
	spawnpoints.shuffle()
	
	for enemies_spawned in enemy_amount:
		var new_enemy 
		
		new_enemy = Resources.zombie.instantiate()

		
		var chosen_spawnpoint = spawnpoints.pop_back().get_child(0)
		
		chosen_spawnpoint.progress_ratio = enemy_rng.randf()
		new_enemy.global_position = chosen_spawnpoint.get_global_position()
		new_enemy.generate_drop.connect(create_drop)
		new_enemy.death.connect(_check_for_enemy)
		new_enemy.add_sword_charge.connect(add_player_sword_charge)
		new_enemy.slow_time.connect(slow_time)
		$Enemies.call_deferred("add_child",new_enemy,true)
