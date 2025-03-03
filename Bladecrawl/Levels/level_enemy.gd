extends "res://Levels/base_level.gd"

var enemy_rng = RandomNumberGenerator.new()
var first_entry = true
var room_cleared = false
var spawnpoints = []


@export var enemy_amount = 2

func _appeared_on_screen():
	if first_entry:
		first_entry = false
		_enemy_spawn()
		_close_door()
	await get_tree().create_timer(1).timeout
	room_entered()
	_check_for_enemy()


func _enemy_spawn():
	enemy_rng.randomize()
	
	spawnpoints = _get_spawnpoints()
	spawnpoints.append_array(spawnpoints)
	spawnpoints.shuffle()
	
	for enemies_spawned in enemy_amount:
		var new_enemy 
		
		var enemy_selection = enemy_rng.randf()
		if enemy_selection < 0.7:
			new_enemy = Resources.zombie.instantiate()
		else:
			new_enemy = Resources.ghostface.instantiate()
		
		var chosen_spawnpoint = spawnpoints.pop_back().get_child(0)
		
		chosen_spawnpoint.progress_ratio = enemy_rng.randf()
		new_enemy.global_position = chosen_spawnpoint.get_global_position()
		new_enemy.generate_drop.connect(create_drop)
		new_enemy.death.connect(_check_for_enemy)
		new_enemy.add_sword_charge.connect(add_player_sword_charge)
		new_enemy.slow_time.connect(slow_time)
		$Enemies.call_deferred("add_child",new_enemy,true)



func _check_for_enemy():
	await get_tree().create_timer(0.5).timeout
	if !room_cleared and $Enemies.get_child_count() <= 0:
		room_cleared = true
		_enable_transition()
		_open_door()

func create_drop(weights,drop_position):
	var drop = DropFactory.generate_drop(weights)
	if drop != null:
		drop.position = drop_position + Vector2(0,-10)
		drop.freeze = false
		drop.linear_velocity = Vector2(0,-500).rotated(randf_range(-0.1,0.1))
		$Drops.call_deferred("add_child",drop)

func add_player_sword_charge(charge):
	if get_parent().has_method("add_player_sword_charged"):
		get_parent().add_player_sword_charge(charge)

func slow_time():
	if get_parent().has_method("slow_time"):
		get_parent().slow_time()
	elif  get_parent().get_parent().has_method("hit_slow"):
		get_parent().get_parent().hit_slow()
