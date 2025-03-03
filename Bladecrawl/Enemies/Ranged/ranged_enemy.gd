extends CharacterBody2D

signal add_sword_charge(charge)
signal death
signal generate_drop(weights)
signal slow_time

var alive: bool = true
var facing_left = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_stunned = false

@export var attacking = false
@export var drop_weights:Array = [15,10,6,2]
@export var health = 3
@export var projectile:PackedScene
@export var score = 50
@export var speed = 300.0
@onready var statemachine = $AnimationTree
@export var stunnable = true


# spawns the enemy facing and moving right
func _ready():
	attacking = false
	velocity.x = speed
	scale.x *= -1



func _physics_process(_delta):
	if alive:
		#stops the enemy from standing still
		if !attacking and !is_stunned:
			if !abs(velocity.x):
				if facing_left:
					velocity.x = -speed
				else:
					velocity.x = speed
				statemachine["parameters/conditions/is_walking"] = true
				statemachine["parameters/conditions/hurt"] = false
				statemachine["parameters/conditions/attack"] = false
				statemachine["parameters/conditions/stunned"] = false
			
			#causes the enemy to fall
			if !is_on_floor():
				velocity.y += gravity * _delta
			
			#turns the enemy around if he reaches the end of a platform or a wall
			if is_on_wall() or (is_on_floor() and !$RayCast2D.is_colliding()):
				velocity.x *= -1
				scale.x *= -1
				facing_left = !facing_left
			
			if $AttackTrigger.is_colliding() and !is_stunned:
				if $AttackTrigger.get_collider() != null:
					if $AttackTrigger.get_collider().has_method("targetable_by_enemy") and $AttackTrigger.get_collider().targetable_by_enemy():
						_attack()
						velocity.x = 0
			
	else:
		statemachine["parameters/conditions/died"] = true
	move_and_slide()

#stuns the enemy
#called by the players dash
func _on_hit_by_dash():
	if stunnable:
		is_stunned = true
		velocity.x = 0
		attacking = false
		statemachine["parameters/conditions/is_walking"] = false
		statemachine["parameters/conditions/hurt"] = false
		statemachine["parameters/conditions/attack"] = false
		statemachine["parameters/conditions/stunned"] = true
		$Timer.start(3)

#damages the enemy if it is stunned
#called by the players attack
func _on_hit_by_player(_player_position, damage, knockback):
	slow_time.emit()
	$Timer.stop()
	#$VFXSprites.play("Hit")
	$AttackTrigger.enabled = false
	attacking = false
	is_stunned = true
	health -= damage
	var player_direction = cos(get_angle_to(_player_position))
	health_changed()
	statemachine["parameters/conditions/is_walking"] = false
	statemachine["parameters/conditions/hurt"] = true
	statemachine["parameters/conditions/attack"] = false
	statemachine["parameters/conditions/stunned"] = false
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
	
	$AttackTrigger.set_deferred("enabled",true)


func health_changed():
	if health <= 0:
		alive = false
		velocity = Vector2.ZERO
		$Timer.stop()
		set_collision_layer_value(2, false)
		$AttackTrigger.enabled = false
		$DeathAudio.play()
		if get_tree().get_first_node_in_group("UI") and get_tree().get_first_node_in_group("UI").has_method("score_update"):
			get_tree().get_first_node_in_group("UI").score_update(score)
		generate_drop.emit(drop_weights,position)
		add_sword_charge.emit(2)
	#else:
		#$HurtAudio.play()

#ends the enemies stun
func _unstun():
	is_stunned = false
	$Timer.stop()
	$StunSprites.hide()

func _attack():
	if alive and !is_stunned and $AnimatedSprite2D.animation != "Hurt" and $AttackCooldown.is_stopped:
		velocity.x = 0
		statemachine["parameters/conditions/is_walking"] = false
		statemachine["parameters/conditions/hurt"] = false
		statemachine["parameters/conditions/attack"] = true
		statemachine["parameters/conditions/stunned"] = false


func _shoot():
	var new_projectile = projectile.instantiate()
	new_projectile.facing_left = facing_left
	new_projectile.position = $AttackTrigger.get_global_position()
	new_projectile.scale.x = self.scale.y
	$Projectiles.add_child(new_projectile)

func end_attack():
	statemachine["parameters/conditions/is_walking"] = true
	statemachine["parameters/conditions/hurt"] = false
	statemachine["parameters/conditions/attack"] = false
	statemachine["parameters/conditions/stunned"] = false


func _on_animation_finished(anim_name):
	if anim_name == &"Death":
		death.emit()
		queue_free()

func on_hit_by_spikes():
	health = 0
	health_changed()
