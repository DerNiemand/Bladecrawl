extends Node2D


func _enter_tree() -> void:
	var jump_vfx_framecount = $Left.texture.frames
	for i in jump_vfx_framecount:
		var frame_image = $Right.texture.get_frame_texture(i).get_image()
		frame_image.flip_x()
		$Left.texture.set_frame_texture(i, ImageTexture.create_from_image(frame_image))
	$Left.texture.current_frame = 0
	$Left.emitting = true
	$Right.texture.current_frame = 0
	$Right.emitting = true

func _on_emiting_finished() -> void:
	await get_tree().create_timer(1).timeout
