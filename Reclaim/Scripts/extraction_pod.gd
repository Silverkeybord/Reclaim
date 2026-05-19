extends StaticBody3D

const ship_scene := "res://Scenes/ship/ship.tscn"


func interact() -> void:
	get_tree().change_scene_to_file(ship_scene)
	Global.at_ship = true
