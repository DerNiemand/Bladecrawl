extends RigidBody2D

enum DropType{
	SCORE,
	HEAL
}

var collectable: bool = false

@export var drop_type = DropType.SCORE
@export var score:int = 10

func _ready():
	await get_tree().create_timer(1).timeout
	collectable  =true

func collected(body):
	if collectable and body.has_method("can_collect_drops"):
		if drop_type == DropType.SCORE and get_tree().get_first_node_in_group("UI").has_method("score_update"):
				get_tree().get_first_node_in_group("UI").score_update(score)
				if get_tree().get_first_node_in_group("Player").has_method("score_gem_collected"):
					get_tree().get_first_node_in_group("Player").score_gem_collected()
		elif drop_type == DropType.HEAL and get_tree().get_first_node_in_group("Player").has_method("heal"):
			get_tree().get_first_node_in_group("Player").heal()
		call_deferred("queue_free")


func on_hit_by_spikes():
	queue_free()
