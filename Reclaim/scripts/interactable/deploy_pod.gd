extends StaticBody3D

const ship_scene := "res://scenes/ship/ship.tscn"


func interact() -> void:
	get_tree().change_scene_to_file(Global.selected_sector_path)
	Global.at_ship = false
