extends Node3D

const valid_color := Color(0.0, 0.431, 0.871, 0.506)
const invalid_color := Color(0.813, 0.0, 0.412, 0.506)

@export var mesh : MeshInstance3D
@export var valid_position := false


func _process(_delta: float) -> void:
	if valid_position:
		mesh.get_surface_override_material(0).albedo_color = valid_color
	else:
		mesh.get_surface_override_material(0).albedo_color = invalid_color
