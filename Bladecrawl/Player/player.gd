extends CharacterBody2D

signal dash_charging(charge)
signal dash_cooldown(cooldown)
signal pause
signal player_damaged(trauma)
signal player_death
signal player_health_changed(health)
signal restart
signal start_transition
signal sword_activated
signal sword_charge_changed(charge)
signal sword_deactivated
signal toggle_map



var alive:bool = true
var attacking:bool = false
var can_transition = false
var coyote_time:float = 0.
var dash_charge:float = 0
var dash_multiplier:float = 0
var dashing_time:float = 0
var dashing = false
var facing_left = false
var first_target_hit = true
var gravity: int
var jump_held: bool = false
var jump_held_time: float = 0
var paused:bool = false
var sword_active = false
var sword_togglable = false
var sword_charge = 0.
var targetable = true
var transitioning = false
var transition_time = 0.5 
var transition_position: float
var transitioning_time = 0
var transition_vector: Vector2


@export var attack_explosion = preload("res://Player/charged_attack_explosion.tscn")
@export var damage_charged = 2
@export var damage_uncharged = 1
@export var dash_charge_time = 1.5
@export var dash_cooldown_time = 2
@export var dash_speed = 2000
@export var health = 3
@export var jump_velocity_max: float = -1300
@export var jump_velocity_min: float = -750
@export var jump_vfx = preload("res://Player/player_jump_vfx.tscn")
@export var knockback_charged = 300
@export var knockback_uncharged = 1300
@export var max_dash_time = 0.2
@onready var player_animations = $LowBladeSprite
@export var required_sword_charge = 3
@export var speed = 400.0
@onready var sword_hit_sfx = $Sword/Hit
@onready var sword_collision: CollisionShape2D = $Sword/LowSwordAttack
@onready var sword_swing_sfx = $Sword/LowBladeSwing


func _ready():
	sword_charge_changed.emit(sword_charge)


func initiate_companion():
	$Companion.initiate($CompanionRestingPosition)


func _physics_process(_delta):
	if alive and !paused:
		
		#handles standard movement
		if !dashing and !transitioning:
			
			#makes the players jump less floaty by increasing deceleration
			if !is_on_floor():
				if velocity.y > 0:
					gravity = 3000
				else:
					gravity = 4500
				
				velocity.y += gravity * _delta
			
			
			if !is_on_floor():
				coyote_time += _delta
			else:
				coyote_time = 0
			
			
			#makes the Player move and face the direction he is moving in
			#when the player stops moving he slows down gradually
			var direction = Input.get_axis("move_left", "move_right")
			if direction:
				velocity.x = direction * speed
				if direction > 0:
					scale.y = 1
					rotation = 0
					facing_left = false
				elif direction < 0:
					scale.y = - 1
					rotation = PI
					facing_left = true
			elif abs(velocity.x) != 750:
				velocity.x = 0
			
			
			#plays the appropriate animation for player action
			if is_on_floor():
				if attacking:
					pass
				elif player_animations.animation == "Hurt" and player_animations.is_playing():
					pass
				elif velocity.x == 0:
					player_animations.animation = "Idle"
					$WalkingVFX.emitting = false
				else:
					player_animations.play("Walking")
					$WalkingVFX.emitting = true
			else:
				$WalkingVFX.emitting = false
			
			#makes the player jump
			if Input.is_action_just_pressed("jump") and coyote_time <= 0.2:
				coyote_time += 1
				jump_held = true
				var vfx_jump = jump_vfx.instantiate()
				vfx_jump.position = global_position
				$PlayerJumpVfx.add_child(vfx_jump)
				player_animations.play("Jumping")
				velocity.y = jump_velocity_max
			
			if Input.is_action_just_pressed("map"):
				toggle_map.emit()
			
			if Input.is_action_just_released("jump"):
				jump_held = false
				if velocity.y <= jump_velocity_min:
					velocity.y = jump_velocity_min
			
			if Input.is_action_just_pressed("activate_sword"):
				if sword_togglable:
					$Sword/AttackCooldown.start(0.5)
					sword_active = true
					sword_activated.emit()
					sword_collision.disabled = true
					sword_collision = $Sword/FullSwordAttack
					$SwordActivationVFX.show()
					$SwordActivationVFX.play("Activation")
					$Companion.transformation($Marker2D)
					sword_togglable = false
					player_animations = $FullBladeSprite
					sword_swing_sfx = $Sword/FullBladeSwing
					$FullBladeSprite.show()
					$LowBladeSprite.hide()
				elif sword_active:
					if sword_charge >= 0.3:
						sword_togglable = true
					deactivate_sword()
			
			
			#plays the attack animation and enables attack collision
			if Input.is_action_just_pressed("attack"):
				if $Sword/AttackCooldown.is_stopped():
					first_target_hit = true
					attack()
			
			
			if Input.is_action_pressed("dash"):
				if $Dash/DashCooldown.is_stopped():
					dash_charge += _delta/dash_charge_time
					dash_charge = clamp(dash_charge,0.,1.0)
					dash_charging.emit(dash_charge)
					$DashChargeVFX.self_modulate = Color(1,1,1,dash_charge)
					velocity.x *= 0.75
			
			
			if Input.is_action_just_released("dash"):
				if $Dash/DashCooldown.is_stopped():
					$Dash/CollisionShape2D.disabled = false
					$Dash/AudioStreamPlayer2D.play(0.48)
					if facing_left:
						$Dash/DashTrailRight.emitting = true
					else:
						$Dash/DashTrailRight.emitting = true
					dashing = true
				dash_multiplier = 0.3 + 0.7 * dash_charge
				dash_charge = 0
				$DashChargeVFX.self_modulate = Color(1,1,1,dash_charge)
				dash_charging.emit(dash_charge)
				
				
			
			if Input.is_action_just_pressed("Interact") and can_transition:
				can_transition = false
				start_transition.emit()
		
		
		#handles the player dashing
		elif !transitioning and dashing:
			dashing_time += _delta * 1 / dash_multiplier
			player_animations.play("Dash")
			#makes the player dash in the direction he is facing
			if facing_left:
				velocity.x = -dash_speed
			else:
				velocity.x = dash_speed
			
			#ends dash after completion and starts cooldown
			if dashing_time >= max_dash_time:
				velocity = Vector2(0,0)
				dashing_time = 0
				dashing = false
				$Dash/CollisionShape2D.disabled = true
				$Dash/DashTrailLeft.emitting = false
				$Dash/DashTrailLeft.texture.current_frame = 0
				$Dash/DashTrailRight.emitting = false
				$Dash/DashTrailRight.texture.current_frame = 0
				$Dash/DashCooldown.start(dash_cooldown_time * dash_multiplier)
				$Dash/IFrames.start()
		
		#handles the Player transitioning between scenes
		elif transitioning:
			$Dash/DashTrailRight.emitting = false
			$Dash/DashTrailRight.texture.current_frame = 0
			$Dash/DashTrailLeft.emitting = false
			$Dash/DashTrailLeft.texture.current_frame = 0
			dashing_time = 0
			dashing = false
			velocity = transition_vector
			transitioning_time += _delta
			if transitioning_time >= transition_time:
				transitioning_time = 0
				transitioning = false
				set_collision_layer_value(3,true)
				set_collision_mask_value(1, true)
				set_collision_layer_value(1,true)
		
		
		if is_on_floor() and velocity.x != 0:
			if !$WalkingAudio.playing:
				$WalkingAudio.playing = true
		else:
			$WalkingAudio.playing = false
		
		move_and_slide()
		if sword_active:
			sword_charging(-_delta)
			if sword_charge <= 0:
				deactivate_sword()
		elif sword_charge <= 10:
			sword_charging(_delta/3)
			
		if !$Dash/DashCooldown.is_stopped():
			dash_cooldown.emit($Dash/DashCooldown.time_left / $Dash/DashCooldown.wait_time)
	elif !paused:
		if Input.is_action_pressed("restart"):
			restart.emit()


#handles the player being hit
#called from enemies uppon collision
func _on_hit_by_enemy(_piercing, _direction):
	if ((!dashing and $Dash/IFrames.is_stopped()) or _piercing) and player_animations.animation != "Hurt":
		health -= 1
		player_damaged.emit(0.7)
		health_decreased()
	take_knockback(_direction)


func on_hit_by_spikes():
	if player_animations.animation != "Hurt":
		health -= 1
		player_damaged.emit(0.7)
		health_decreased()

func on_hit_by_flames():
	if player_animations.animation != "Hurt" and !dashing:
		health -= 1
		player_damaged.emit(0.7)
		health_decreased()

func health_decreased():
	player_health_changed.emit(health)
	player_animations.play("Hurt")
	
	if health <= 0:
		alive = false
		$PlayerCollision.set_deferred("disabled", true)
		velocity = Vector2(0,0)
		if get_tree().get_first_node_in_group("UI").has_method("show_restart"):
			get_tree().get_first_node_in_group("UI").show_restart()
		player_animations.scale = Vector2(1,1)
		player_animations.animation = "Death"
		$AnimationPlayer.pause()
		player_death.emit()


#handles the player hitting an enemy
func _on_sword_hit(_body):
	if _body.has_method("_on_hit_by_player"):
		var space_state = get_world_2d().direct_space_state
		for i in 3:
			var querry = PhysicsRayQueryParameters2D.create(global_position, _body.global_position + Vector2(0,-50 * i))
			querry.hit_from_inside = true
			querry.collision_mask = 2
			var result = space_state.intersect_ray(querry)
			if result.size() != 0 and result["collider"].has_method("_on_hit_by_player"):
				if sword_active:
					sword_hit_sfx.play()
					_body._on_hit_by_player(self.position, damage_charged, knockback_charged)
				elif first_target_hit:
					sword_hit_sfx.play()
					first_target_hit = false
					_body._on_hit_by_player(self.position, damage_uncharged, knockback_uncharged)
				break


#handles the player dashing into enemies
func _on_dash_hit(_body):
	if dashing:
		sword_charging(2)
		if _body.has_method("_on_hit_by_dash"):
			_body._on_hit_by_dash()
		elif _body.get_parent().has_method("_on_hit_by_dash"):
			_body.get_parent()._on_hit_by_dash()


func sword_charging(charge):
	sword_charge += charge
	sword_charge = clamp(sword_charge,0.,10)
	sword_charge_changed.emit(sword_charge/10)
	if sword_charge >= required_sword_charge and !sword_active:
		sword_togglable = true


#starts the transition between scenes
func transition(direction):
	if !transitioning:
		set_collision_layer_value(3,false)
		set_collision_mask_value(1, false)
		set_collision_layer_value(1,false)
		transitioning = true
		position.x = transition_position
		if direction == 0:
			transition_vector = Vector2(speed,0)
			scale.y = 1
			rotation = 0
			facing_left = false
		
		elif direction == 4:
			transition_vector = Vector2(0,-jump_velocity_max/2.5)
		
		elif direction == 8:
			transition_vector = Vector2(-speed,0)
			scale.y = - 1
			rotation = PI
			facing_left = true
		
		elif direction == 12:
			transition_vector = Vector2(0,jump_velocity_max/2.2)


func targetable_by_enemy():
	return targetable


func can_collect_drops():
	return true


func deactivate_sword():
	sword_active = false
	sword_collision.disabled = true
	sword_collision = $Sword/LowSwordAttack
	sword_deactivated.emit()
	$Companion.reapear()
	sword_swing_sfx = $Sword/LowBladeSwing
	player_animations = $LowBladeSprite
	$LowBladeSprite.show()
	$FullBladeSprite.hide()


func attack():
	attacking = true
	if sword_active == true:
		$Attack_Explosions.add_child(attack_explosion.instantiate())
	$Sword/AttackCooldown.start(0.4)
	player_animations.play("Attacking")
	$AnimationPlayer.play("Attack")
	await $AnimationPlayer.animation_finished
	attacking = false


func take_knockback(_direction):
	if _direction < 0:
		velocity.x = 750
		await get_tree().create_timer(0.2).timeout
		velocity.x = 0
	else:
		velocity.x = -750
		await get_tree().create_timer(0.2).timeout
		velocity.x = 0

func sword_swing_sound():
	sword_swing_sfx.play()

func  transition_available(_transition_position):
	transition_position = _transition_position
	can_transition = true

func transition_unavailable():
	can_transition = false


func _on_sword_activation_finished() -> void:
	$SwordActivationVFX.hide()
	$Companion.light_off()

func heal():
	health += 1
	health = min(health,4)
	player_health_changed.emit(health)
	$OverlayVFX.show()
	$OverlayVFX.play("Heal")
	await $OverlayVFX.animation_finished
	$OverlayVFX.hide()

func score_gem_collected():
	$OverlayVFX.show()
	$OverlayVFX.play("ScoreGem")
	await $OverlayVFX.animation_finished
	$OverlayVFX.hide()

func enable_sword_hitbox():
	sword_collision.disabled = false

func disable_sword_hitbox():
	sword_collision.disabled = true
