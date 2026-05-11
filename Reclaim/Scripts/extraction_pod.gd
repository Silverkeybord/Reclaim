extends StaticBody3D

const remote_island_scene := "res://Scenes/maps/remote_island.tscn"


func interact() -> void:
	get_tree().change_scene_to_file(remote_island_scene)
