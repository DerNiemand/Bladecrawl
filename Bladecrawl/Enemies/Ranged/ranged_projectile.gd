extends RigidBody2D

var facing_left: bool

@export var piercing: bool = true
@export var projectile_speed: int = 100


func _ready():
	_windup()

func _windup():
	$AnimatedSprite2D.play("Windup")
	await $AnimatedSprite2D.animation_finished
	_shoot()

func _shoot():
	freeze = false
	if scale.x <= 0:
		linear_velocity.x = projectile_speed
	else:
		linear_velocity.x = -projectile_speed
	$AnimatedSprite2D.play("Attack")

#deals damage to whatever it hits
func _on_hit(_body):
	if _body.has_method("_on_hit_by_enemy"):
		var direction_to_player = cos(get_angle_to(_body.position))
		if facing_left:
			direction_to_player *= -1
		_body._on_hit_by_enemy(piercing, direction_to_player)
	call_deferred("queue_free")

