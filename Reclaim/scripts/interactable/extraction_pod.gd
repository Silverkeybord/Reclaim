extends StaticBody3D

const ship_scene := "res://scenes/ship/ship.tscn"


func interact() -> void:
	Global.at_ship = true
	get_tree().change_scene_to_file(ship_scene)
