extends Node3D

@export var xy_camera_marker: Marker3D
@export var z_camera_marker: Marker3D
@export var lerp_power: float = 1.0

func _process(delta: float) -> void:
	position = lerp(
		position, 
		Vector3(
			z_camera_marker.position.z,
			0,
			xy_camera_marker.position.z
		), 
		delta * lerp_power
	)
