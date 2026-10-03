extends Camera3D

@export_group("Camera Properties")
@export var max_offset : float = 15.0
@export var height : float = 10.0
@export var build_camera_speed := 25.0


func _ready() -> void:
	position.y = height


func _process(delta):
	if not Global.top_down_build_view:
		return
	
	if current:
		var direction := Vector3.ZERO
		
		if Input.is_key_pressed(KEY_W):
			direction.z -= 1
		if Input.is_key_pressed(KEY_S):
			direction.z += 1
		if Input.is_key_pressed(KEY_A):
			direction.x -= 1
		if Input.is_key_pressed(KEY_D):
			direction.x += 1
		
		if direction != Vector3.ZERO:
			direction = direction.normalized()
			
			global_position += direction * build_camera_speed * delta
	
	global_position = Vector3(
		clamp(global_position.x, -max_offset, max_offset),
		height,
		clamp(global_position.z, -max_offset, max_offset)
	)
