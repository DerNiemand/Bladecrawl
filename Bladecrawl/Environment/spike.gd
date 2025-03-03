extends StaticBody2D

func _on_body_entered(body):
	if body.has_method("on_hit_by_spikes"):
		body.on_hit_by_spikes()
