extends AudioStreamPlayer


func _on_finished() -> void:
	Global.sounds -= 1
	queue_free()
