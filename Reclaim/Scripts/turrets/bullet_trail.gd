extends MeshInstance3D

const TRAIL_THICKNESS := 0.5

@export var trail : Resource


func create_bullet_trail(start_pos: Vector3, end_pos: Vector3):
	var draw_mesh = BoxMesh.new()
	var distance = start_pos.distance_to(end_pos)
	
	draw_mesh.size = Vector3(TRAIL_THICKNESS, TRAIL_THICKNESS, distance)
	mesh = draw_mesh
	
	global_position = (start_pos + end_pos) / 2
	look_at(end_pos)


func _on_timer_timeout() -> void:
	queue_free()
