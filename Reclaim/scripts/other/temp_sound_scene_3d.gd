extends AudioStreamPlayer3D


func _on_finished() -> void:
	HelperFunctions.sounds -= 1
	queue_free()
