extends AudioStreamPlayer


func _on_finished() -> void:
	HelperFunctions.sounds = maxi(HelperFunctions.sounds - 1, 0)
	queue_free()
