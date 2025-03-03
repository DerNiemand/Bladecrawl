extends Node

#based on pattern 4 from https://www.lkokemohr.de/factory_pattern.html

var rng = RandomNumberGenerator.new()

func generate_drop(weights:Array):
	rng.randomize()
	
	var drop_weight = rng.randi_range(0,100)
	var index = 0
	var sum = 0
	
	for val in weights:
		sum += val
		if sum >= drop_weight:
			return get_drop(index)
		index += 1
	

func get_drop(index):
	return get_child(index).duplicate()
