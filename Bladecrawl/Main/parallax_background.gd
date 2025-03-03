extends Node2D


func _process(delta):
	$CanvasLayer/Camera2D.position.x += 200 * delta
	
