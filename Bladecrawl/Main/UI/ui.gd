extends Control

var player: CharacterBody2D
var score = 0
var charge_sword = 0
var health_bar_values: Array = [0,17,42,70,100]


@onready var swordbar = $StatBars/SwordCharge
@onready var swordflame = $StatBars/SwordFlame

func recieve_player(_player):
	player = _player

func remove_player():
	player = null

func _process(_delta: float) -> void:
	if player:
		$TransitionButtonPrompt.position = Vector2(int(player.position.x) % 1920, int(player.position.y) % 1080) + Vector2(-20,-100) 


func _player_health_changed(health):
	$StatBars/HealthBar.value = health_bar_values[health]

func _dash_charge(_charge):
	$StatBars/DashBar.value = _charge

func score_update(added_score):
	score += added_score
	if score <= 99999:
		$Score/ScoreValue.text = str(score)
	else:
		$Score/ScoreValue.text = "A LOT"

func show_restart():
	$Restart/ScoreScroll.visible = $Score.visible
	$Restart/Score.visible = $Score.visible
	$Restart/Score/DeathScore.text = "Score " + str(score)
	if score > Resources.highscore:
		Resources.highscore = score
		Resources.save_new_highscore()
		$Restart/Score/NewHighscore.visible = true
	$Restart/Score/HighScore.text = "Highscore " + str(Resources.highscore)
	$Restart.visible = true

func hide_restart():
	$Restart.visible = false

func sword_charge(_charge):
	charge_sword = _charge
	if swordbar:
		swordbar.value = charge_sword
	if swordflame:
		swordflame.value = charge_sword


func sword_activated():
	swordflame.show()

func sword_deactivated():
	swordflame.hide()

func transition_available():
	$TransitionButtonPrompt.show()

func transition_unavailable():
	$TransitionButtonPrompt.hide()
