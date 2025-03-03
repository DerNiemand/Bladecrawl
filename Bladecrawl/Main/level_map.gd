extends TileMap

signal add_sword_charge(charge)
signal hit_slow
signal ladder_climbing(state, gravity)
signal level_transition_available(direction)
signal level_transition_unavailable
signal new_room_entered(room, has_portal)

var cell = Vector2i(0,0)
var neighbor

func set_starting_cell(starting_cell):
	cell = starting_cell

func transition_available(direction, transition_position):
	level_transition_available.emit(direction, transition_position)

func transition_unavailable():
	level_transition_unavailable.emit()

func check_neighbor(direction, transition_position):
	neighbor = get_neighbor_cell(cell,direction)
	if get_cell_source_id(0,neighbor) != -1:
		transition_available(direction, transition_position)

func on_new_room_entered(has_portal):
	new_room_entered.emit(cell, has_portal)

func get_camera_position():
	return Vector2(1920*cell.x + 960, 1080*cell.y + 540)

func add_player_sword_charge(charge):
	add_sword_charge.emit(charge)

func slow_time():
	hit_slow.emit()

func transitioned():
	cell = neighbor

func get_doors(room_position) -> Array:
	var travel_possible: Array = []
	var possiblle_directions: Array = [0,4,8,12]
	for val in  possiblle_directions:
		var neighbor_room: Vector2i = get_neighbor_cell(local_to_map(room_position), val)
		travel_possible.append(get_cell_source_id(0,neighbor_room) != -1)
	return travel_possible
