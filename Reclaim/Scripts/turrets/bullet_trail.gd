extends Node3D

const CYLINDAR_ROTATION := Vector3(PI / 2, 0, 0)

@export var trail: BulletTrailData
@export var timer: Timer
@export var trail_mesh: MeshInstance3D

@export var default_material: Material


func _ready() -> void:
	if trail == null or timer == null or trail_mesh == null:
		queue_free()
		return

	# starts the timer so the trail deletes after its life ends
	timer.wait_time = trail.life
	timer.start()
	
	if trail.fade:
		# makes the material unique so only this bullet trail fades
		var unique_mat: Material
		
		if trail.material:
			unique_mat = trail.material.duplicate() as Material
		elif default_material:
			unique_mat = default_material.duplicate() as Material
		
		var fade_material := unique_mat as StandardMaterial3D
		if fade_material == null:
			return

		trail_mesh.set_surface_override_material(0, fade_material)
		
		var fade_tween := create_tween()
		fade_tween.set_ease(Tween.EASE_OUT)
		
		var target_color := fade_material.albedo_color
		target_color.a = 0.0
		
		fade_tween.tween_property(fade_material, "albedo_color", target_color, trail.life)


func create_bullet_trail(start_pos: Vector3, end_pos: Vector3) -> void:
	if trail == null or trail_mesh == null:
		queue_free()
		return

	var distance: float = start_pos.distance_to(end_pos)
	if is_zero_approx(distance):
		queue_free()
		return

	var draw_mesh: Mesh = null
	
	# PHASE 1: Shape Setup (Keep this strictly for initialization)
	match trail.shape:
		trail.SHAPES.SQUARE:
			draw_mesh = BoxMesh.new()
			draw_mesh.size = Vector3(trail.size, trail.size, distance)
			
		trail.SHAPES.CLYINDER:
			draw_mesh = CylinderMesh.new()
			draw_mesh.top_radius = trail.size
			draw_mesh.bottom_radius = trail.size
			draw_mesh.height = distance
			trail_mesh.rotation = CYLINDAR_ROTATION
		_:
			queue_free()
			return
			
	# Assign the freshly generated mesh to the node
	trail_mesh.mesh = draw_mesh
	
	global_position = (start_pos + end_pos) / 2
	look_at(end_pos)
	
	# if the expand option is pressed will expand the bullet trail
	if trail.expand:
		var target_size: float = trail.size + trail.expand_size
		var expand_tween := create_tween()
		expand_tween.set_ease(Tween.EASE_OUT)
		
		# different shapes will have different ways of expanding
		if draw_mesh is BoxMesh:
			var target_vector3 := Vector3(target_size, target_size, distance)
			expand_tween.tween_property(trail_mesh.mesh, "size", target_vector3, trail.life)
			
		elif draw_mesh is CylinderMesh:
			expand_tween.set_parallel(true)
			expand_tween.tween_property(trail_mesh.mesh, "top_radius", target_size, trail.life)
			expand_tween.tween_property(trail_mesh.mesh, "bottom_radius", target_size, trail.life)


func _on_timer_timeout() -> void:
	queue_free()
