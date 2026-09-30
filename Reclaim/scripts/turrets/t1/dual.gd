extends TurretBasics

@export var left_marker: Marker3D
@export var right_marker: Marker3D

var left_last_barrel_shot := true


func shoot(target: CharacterBody3D) -> void:
	if (
		target == null
		or not is_instance_valid(target)
		or turret_resource == null
		or turret_pivot_point == null
		or left_marker == null
		or right_marker == null
		or not target.has_method(&"hit")
	):
		return

	var target_position := target.global_position
	turret_pivot_point.look_at(target_position)
	
	if turret_resource.get_critical():
		target.call(
			&"hit",
			turret_resource.damage * turret_resource.critical_multiplier,
			true
		)
	else:
		target.call(&"hit", turret_resource.damage)
	
	var shot_origin: Marker3D = right_marker if left_last_barrel_shot else left_marker
	left_last_barrel_shot = not left_last_barrel_shot
	
	HelperFunctions.create_bullet_trail(shot_origin.global_position, target_position)
	if not turret_resource.shooting_sound.is_empty():
		HelperFunctions.spawn_temp_sound(
			turret_resource.shooting_sound.pick_random(),
			shot_origin.global_position
		)
