extends CharacterBody2D

signal add_sword_charge(charge)
signal death
signal generate_drop(weights)
signal slow_time

var alive = true
var damagable = true
var facing_left = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_stunned = false
var piercing = false
var speed = 0
var target
var target_in_view: bool = false


@export var alerted_speed = 500.0
@export var attacking = false
@export var calm_speed = 250.0
@export var drop_weights:Array = [10,5,85]
@export var health = 3
@export var score = 10
@onready var statemachine = $AnimationTree

# spawns the enemy facing and moving right
func _ready():
	attacking = false
	speed = calm_speed
	velocity.x = speed
	scale.x *= -1



func _physics_process(_delta):
	if alive:
		if !attacking and !is_stunned:
			if target:
				$PlayerDetection.target_position = to_local(Vector2(target.position.x, target.position.y + 55))
				if $PlayerDetection.is_colliding() and $PlayerDetection.get_collider() != null:
					if $PlayerDetection.get_collider().has_method("targetable_by_enemy"):
						target_in_view = $PlayerDetection.get_collider().targetable_by_enemy()
					else:
						target_in_view = false
			
			if target_in_view:
				speed = alerted_speed 
			else:
				speed = calm_speed
			
			if $PlayerDetection.target_position.x > 30 and target_in_view:
				velocity.x *= -1
				scale.x *= -1
				facing_left = !facing_left
			
			if abs(velocity.x) != speed and !is_stunned and is_on_floor():
				if facing_left:
					velocity.x = -speed
				else:
					velocity.x = speed
				statemachine["parameters/conditions/is_walking"] = true
				statemachine["parameters/conditions/hurt"] = false
				statemachine["parameters/conditions/attack"] = false
				statemachine["parameters/conditions/stunned"] = false
				statemachine["parameters/conditions/is_idle"] = false
			
			#turns the enemy around if he reaches the end of a platform or a wall
			if !target_in_view and (is_on_wall() or (is_on_floor() and !$RayCast2D.is_colliding())):
				velocity.x *= -1
				scale.x *= -1
				facing_left = !facing_left
			elif target_in_view and is_on_floor() and !$RayCast2D.is_colliding():
				velocity.x = 0
				statemachine["parameters/conditions/is_walking"] = false
				statemachine["parameters/conditions/hurt"] = false
				statemachine["parameters/conditions/attack"] = false
				statemachine["parameters/conditions/stunned"] = false
				statemachine["parameters/conditions/is_idle"] = true
			
			if $Bite/AttackTrigger.is_colliding() and !is_stunned and !$AnimatedSprite2D.animation == "Hurt" and !attacking:
				_attack()
				velocity.x = 0
			
			if is_on_floor() and velocity.x != 0:
				if !$WalkingAudio.playing:
					$WalkingAudio.playing = true
			else:
				$WalkingAudio.playing = false
			
			#causes the enemy to fall
		if !is_on_floor():
			velocity.y += gravity * _delta
	
	else:
		statemachine["parameters/conditions/died"] = true
	move_and_slide()


#stuns the enemy
#called by the players dash
func _on_hit_by_dash():
	is_stunned = true
	velocity.x = 0
	attacking = false
	statemachine["parameters/conditions/is_walking"] = false
	statemachine["parameters/conditions/hurt"] = false
	statemachine["parameters/conditions/attack"] = false
	statemachine["parameters/conditions/stunned"] = true
	statemachine["parameters/conditions/is_idle"] = false
	$Timer.start(3)

#damages the enemy if it is stunned
#called by the players attack
func _on_hit_by_player(_player_position, damage, knockback):
	slow_time.emit()
	$Timer.stop()
	$VFXSprites.play("Hit")
	$Bite/AttackTrigger.enabled = false
	$PlayerDetection.enabled = false
	if damagable:
		attacking = false
		$Bite/CollisionShape2D.set_deferred("disabled",true)
		is_stunned = true
		damagable = false
		health -= damage
		var player_direction = cos(get_angle_to(_player_position))
		health_changed()
		statemachine["parameters/conditions/is_walking"] = false
		statemachine["parameters/conditions/hurt"] = true
		statemachine["parameters/conditions/attack"] = false
		statemachine["parameters/conditions/stunned"] = false
		statemachine["parameters/conditions/is_idle"] = false
		if alive:
			var player_behind = player_direction > 0
			if facing_left:
				player_direction *= -1
			
			if player_direction > 0:
				velocity.x = knockback
				await get_tree().create_timer(0.2).timeout
				velocity.x = 0
			elif player_direction < 0:
				velocity.x = - knockback
				await get_tree().create_timer(0.2).timeout
				velocity.x = 0
			
			if player_behind:
				velocity.x *= -1
				scale.x *= -1
				facing_left = !facing_left
	
	$Bite/AttackTrigger.set_deferred("enabled",true)
	$PlayerDetection.enabled = true
	damagable = true


#ends the enemies stun
func _unstun():
	is_stunned = false
	attacking = false
	$Timer.stop()
	$StunSprites.hide()


#deals damage to whatever it hits
func _on_hit(_body):
	if _body.has_method("_on_hit_by_enemy") and !is_stunned:
		var direction_to_player = cos(get_angle_to(_body.position))
		if facing_left:
			direction_to_player *= -1
		_body._on_hit_by_enemy(piercing,direction_to_player)


func _attack():
	if alive and !is_stunned and $AnimatedSprite2D.animation != "Hurt":
		velocity.x = 0
		statemachine["parameters/conditions/is_walking"] = false
		statemachine["parameters/conditions/hurt"] = false
		statemachine["parameters/conditions/attack"] = true
		statemachine["parameters/conditions/stunned"] = false
		statemachine["parameters/conditions/is_idle"] = false


func health_changed():
	if health <= 0:
		alive = false
		velocity = Vector2.ZERO
		$Timer.stop()
		set_collision_layer_value(2, false)
		$Bite/AttackTrigger.enabled = false
		$DeathAudio.play()
		if get_tree().get_first_node_in_group("UI") and get_tree().get_first_node_in_group("UI").has_method("score_update"):
			get_tree().get_first_node_in_group("UI").score_update(score)
		generate_drop.emit(drop_weights,position)
		add_sword_charge.emit(2)
		await  $DeathAudio.finished
		death.emit()
		queue_free()
	else:
		$HurtAudio.play()

func end_attack():
	statemachine["parameters/conditions/is_walking"] = true
	statemachine["parameters/conditions/hurt"] = false
	statemachine["parameters/conditions/attack"] = false
	statemachine["parameters/conditions/stunned"] = false
	statemachine["parameters/conditions/is_idle"] = false


func _on_detection_area_entered(body: Node2D) -> void:
	if body.has_method("targetable_by_enemy") and body.targetable_by_enemy():
		target = body


func _on_detection_area_exited(body: Node2D) -> void:
	if body == target:
		target = null
		target_in_view = 0

func on_hit_by_spikes():
	health = 0
	health_changed() 
