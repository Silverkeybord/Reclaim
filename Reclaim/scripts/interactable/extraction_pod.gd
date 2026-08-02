extends StaticBody3D

const ship_scene := "res://scenes/ship.tscn"

@export var extraction_ui : ExtractionUI


func interact() -> void:
	extraction_ui.open_ui()


func extract() -> void:
	Global.set_mouse_captured(true, true)
	Global.at_ship = true
	
	if Global.ui_open:
		Global.ui_open = false
		Global.storage_open = false
		Global.crafting_open = false
		Global.extraction_open = false
	
	get_tree().change_scene_to_file(ship_scene)
