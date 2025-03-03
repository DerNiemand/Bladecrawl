extends AnimatedSprite2D

var resting_place = null
var transformed = false
var transformation_point = Vector2(0,0)

@export  var speed = 3.

func initiate(target_position):
	resting_place = target_position
	reapear()


func _process(delta):
	if resting_place != null and !transformed:
		global_position = global_position.lerp(resting_place.global_position, delta * speed)
		
		if Vector2(resting_place.global_position - global_position).x > 0.5:
			flip_h = false
		elif Vector2(resting_place.global_position - global_position).x < -0.5:
			flip_h = true
			
		if Vector2(resting_place.global_position-global_position).length() >= 2.5 and flip_h:
			rotation = -0.4
		elif Vector2(resting_place.global_position-global_position).length() >= 2.5:
			rotation = 0.4
		else:
			rotation = 0
	elif transformed:
		global_position = global_position.lerp(transformation_point.global_position, delta * speed*1.5)


func transformation(_transformation_point):
	transformation_point = _transformation_point
	transformed = true
	play("Transformation")
	$PointLight2D.show()
	await animation_finished
	hide()

func reapear():
	$PointLight2D.hide()
	play("Appear")
	transformed = false
	global_position = resting_place.global_position
	show()
	await animation_finished
	play("Flying")

func light_off():
	$PointLight2D.hide()
	
