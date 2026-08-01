extends StaticBody3D

const ship_scene := "res://scenes/ship.tscn"

@export var extraction_ui : ExtractionUI


func interact() -> void:
	extraction_ui.open_ui()


func extract() -> void:
	Global.set_mouse_captured(true, true)
	Global.at_ship = true
	get_tree().change_scene_to_file(ship_scene)
