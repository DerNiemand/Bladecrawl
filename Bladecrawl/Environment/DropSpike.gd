extends RigidBody2D

var can_check = true
var target


@export var drop_chance = 0.5

func _process(_delta):
	if target:
		
		$RayCast2D.target_position = to_local(target.position)
		if $RayCast2D.is_colliding():
			if $RayCast2D.get_collider().has_method("targetable_by_enemy") and can_check:
				can_check = false
				if randf() < drop_chance:
					drop()
				else:
					shake()
			if !$RayCast2D.get_collider().has_method("targetable_by_enemy") and !can_check and !$AnimationPlayer.is_playing():
				can_check = true

func _on_body_entered(body):
	if body.has_method("on_hit_by_spikes"):
		body.on_hit_by_spikes()
	if freeze == false:
		call_deferred("queue_free")


func _on_detection_area_entered(body):
	if body.has_method("targetable_by_enemy") and body.targetable_by_enemy():
		target = body

func drop():
	$CollisionPolygon2D.set_deferred("scale", Vector2(0.6,0.6))
	$Area2D/CollisionPolygon2D.set_deferred("scale", Vector2(0.6,0.6))
	$Sprite2D.set_deferred("scale", Vector2(0.6,0.6))
	set_deferred("freeze", false)

func shake():
	$AnimationPlayer.play("Shake")


func _on_detection_area_exited(body):
	if body == target:
		can_check = true
		target = null
