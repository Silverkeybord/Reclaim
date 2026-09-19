extends Control

var finished_loading: bool = false

@export var min_loading_timer : Timer
@export var ship_scene : PackedScene


func _ready() -> void:
	min_loading_timer.start()
	await Global.load_game()
	finished_loading = true
	
	if min_loading_timer.is_stopped():
		get_tree().change_scene_to_packed(ship_scene)


func _on_min_loading_timer_timeout() -> void:
	if finished_loading:
		get_tree().change_scene_to_packed(ship_scene)
