class_name TurretRangeArea

extends Area3D
## Tracks valid enemies inside a turret's range and returns a target

var in_range_enemies: Array[base_enemy] = []


func get_target() -> base_enemy:
	var target: base_enemy = null
	
	for enemy in in_range_enemies:
		if target == null:
			target = enemy
			continue
		
		var enemy_distance := global_position.distance_to(enemy.global_position)
		var target_distance := global_position.distance_to(target.global_position)
		
		if enemy_distance < target_distance:
			target = enemy
	
	return target


func _on_body_entered(body: Node3D) -> void:
	var enemy := body as base_enemy
	
	if not _is_valid_target(enemy):
		return
	
	if enemy not in in_range_enemies:
		in_range_enemies.append(enemy)
	
	if not enemy.died.is_connected(_on_enemy_died):
		enemy.died.connect(_on_enemy_died)


func _on_body_exited(body: Node3D) -> void:
	var enemy := body as base_enemy
	in_range_enemies.erase(enemy)


func _is_valid_target(enemy: base_enemy) -> bool:
	return (
		is_instance_valid(enemy)
		and enemy.valid
		and not enemy.is_dead
		and not enemy.is_queued_for_deletion()
	)


func _on_enemy_died(enemy: base_enemy) -> void:
	in_range_enemies.erase(enemy)
