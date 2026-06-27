extends StaticBody3D

const CLOSE_DISTANCE := 10.0

@export var storage_ui : CanvasLayer

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")


func interact() -> void:
	storage_ui.open_or_close()


func _process(_delta: float) -> void:
	if not Global.storage_open:
		return
	
	if global_position.distance_to(player.global_position) > CLOSE_DISTANCE:
		storage_ui.open_or_close()
