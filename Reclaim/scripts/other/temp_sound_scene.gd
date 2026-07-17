extends AudioStreamPlayer


func _on_finished() -> void:
	HelperFunctions.sounds -= 1
	queue_free()
