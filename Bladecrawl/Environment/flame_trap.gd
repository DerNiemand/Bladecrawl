extends Area2D

func _ready() -> void:
	$BaseSprite2D.scale = Vector2(0.344,0.203)/scale

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("on_hit_by_flames"):
		body.on_hit_by_flames()
