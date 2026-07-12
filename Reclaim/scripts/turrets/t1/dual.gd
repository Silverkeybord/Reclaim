extends TurretBasics

@export var left_marker : Marker3D
@export var right_marker : Marker3D

var left_last_barrel_shot := true


func shoot(target : CharacterBody3D) -> void:
	var target_position := target.global_position
	turret_piviot_point.look_at(target_position)
	
	if turret_resource.get_critical():
		target.hit(turret_resource.damage * turret_resource.critical_multiplier, true)
	else:
		target.hit(turret_resource.damage)
	
	var shot_origin = right_marker if left_last_barrel_shot else left_marker
	left_last_barrel_shot = not left_last_barrel_shot
	
	Global.create_bullet_trail(shot_origin.global_position, target_position)
	Global.spawn_temp_sound(
		turret_resource.shooting_sound.pick_random(), 
		shot_origin.global_position
		)
