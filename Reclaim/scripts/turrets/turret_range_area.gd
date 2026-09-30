class_name TurretRangeArea
extends Area3D
## Tracks valid enemies inside a turret's range and returns a target

var in_range_enemies: Array[BaseEnemy] = []


func get_valid_enemies() -> Array[BaseEnemy]:
	var valid: Array[BaseEnemy] = []
	for enemy in in_range_enemies:
		if (
			is_instance_valid(enemy)
			and not enemy.is_queued_for_deletion()
			and enemy.valid
			and not enemy.is_dead
		):
			valid.append(enemy)
	return valid


func get_target() -> BaseEnemy:
	var valid_enemies := get_valid_enemies()
	if valid_enemies.is_empty():
		return null

	var target: BaseEnemy = valid_enemies[0]
	for i in range(1, valid_enemies.size()):
		var enemy: BaseEnemy = valid_enemies[i]
		var enemy_distance := global_position.distance_to(enemy.global_position)
		var target_distance := global_position.distance_to(target.global_position)

		if enemy_distance < target_distance:
			target = enemy

	return target


func _on_body_entered(body: Node3D) -> void:
	var enemy := body as BaseEnemy
	
	if not _is_valid_target(enemy):
		return
	
	if enemy not in in_range_enemies:
		in_range_enemies.append(enemy)
	
	if not enemy.died.is_connected(_on_enemy_died):
		enemy.died.connect(_on_enemy_died)


func _on_body_exited(body: Node3D) -> void:
	var enemy := body as BaseEnemy
	in_range_enemies.erase(enemy)


func _is_valid_target(enemy: BaseEnemy) -> bool:
	return (
		is_instance_valid(enemy)
		and enemy.valid
		and not enemy.is_dead
		and not enemy.is_queued_for_deletion()
	)


func _on_enemy_died(enemy: BaseEnemy) -> void:
	in_range_enemies.erase(enemy)
