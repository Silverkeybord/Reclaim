class_name TurretBasics
extends Builds

enum SHOOTING_METHODS {
	CLOSEST,
	FARTHEST,
	FIRST,
	LAST,
	STRONG,
	RANDOM,
}

const FIRST_SHOT_TIMER_WAIT := 0.01

@export var turret_shooting_type := SHOOTING_METHODS.CLOSEST

@export_group("in scene")
@export var main_body: Node3D
@export var turret_pivot_point: Node3D
@export var bullet_spawn: Marker3D
@export var cooldown_timer: Timer
@export var turret_range_area: TurretRangeArea
@export var turret_range_coll: CollisionShape3D

@export_group("turret_stats")
@export var turret_resource: TurretData
# when godot detects that the variable will be changed from the timer ending
# and setting the value to false, it runs the code underneath. The value is the
# value its going to be set to then some basic logic is run to optmise code
@export var place_cooldown_active := true:
	set(value):
		place_cooldown_active = value
		
		if place_cooldown_active:
			_stop_shoot_timer()
		else:
			_start_shoot_timer(true)


func _ready() -> void:
	if cooldown_timer == null or turret_resource == null:
		return

	cooldown_timer.wait_time = turret_resource.cooldown
	cooldown_timer.one_shot = true
	
	if not place_cooldown_active:
		_start_shoot_timer(true)


func _set_new_turret(key: String) -> void:
	if key.is_empty() or not DataRegistry.turrets.has(key):
		return

	turret_resource = DataRegistry.turrets[key]


# SHOOTING LOGIC --------------------------------------------------------------
func _shooting_logic() -> void:
	if turret_range_area == null or turret_resource == null:
		return
	
	var valid_enemies: Array[BaseEnemy] = turret_range_area.get_valid_enemies()
	
	if valid_enemies.is_empty():
		return
	
	var target: BaseEnemy = _pick_target(valid_enemies)
	
	if target == null or not is_instance_valid(target):
		return
	
	shoot(target)


func shoot(target: BaseEnemy) -> void:
	if (
		target == null
		or not is_instance_valid(target)
		or target.is_dead
		or not target.valid
		or turret_resource == null
		or turret_pivot_point == null
		or bullet_spawn == null
		or not is_instance_valid(bullet_spawn)
	):
		return

	var target_position := target.global_position
	turret_pivot_point.look_at(target_position)
	
	if turret_resource.get_critical():
		target.hit(turret_resource.damage * turret_resource.critical_multiplier, true)
	else:
		target.hit(turret_resource.damage)
	
	HelperFunctions.create_bullet_trail(bullet_spawn.global_position, target_position)
	if not turret_resource.shooting_sound.is_empty():
		HelperFunctions.spawn_temp_sound(
			turret_resource.shooting_sound.pick_random(),
			bullet_spawn.global_position
		)


func _pick_target(enemies: Array[BaseEnemy]) -> BaseEnemy:
	if enemies.is_empty():
		return null
	if main_body == null:
		return enemies[0]

	match turret_shooting_type:
		SHOOTING_METHODS.CLOSEST:
			var closest: BaseEnemy = enemies[0]
			for enemy in enemies:
				if (
					main_body.global_position.distance_to(enemy.global_position)
					< main_body.global_position.distance_to(closest.global_position)
				):
					closest = enemy
			return closest
		
		SHOOTING_METHODS.FARTHEST:
			var farthest: BaseEnemy = enemies[0]
			for enemy in enemies:
				if (
					main_body.global_position.distance_to(enemy.global_position)
					> main_body.global_position.distance_to(farthest.global_position)
				):
					farthest = enemy
			return farthest
		
		SHOOTING_METHODS.FIRST:
			# First enemy to enter range (earliest in the array)
			return enemies[0]
		
		SHOOTING_METHODS.LAST:
			# Last enemy to enter range
			return enemies[-1]
		
		SHOOTING_METHODS.STRONG:
			# Enemy with the most health remaining
			var strongest: BaseEnemy = enemies[0]
			for enemy in enemies:
				if enemy.health > strongest.health:
					strongest = enemy
			return strongest
		
		SHOOTING_METHODS.RANDOM:
			return enemies[randi() % enemies.size()]
	
	return enemies[0]


func _on_cool_down_timer_timeout() -> void:
	if place_cooldown_active:
		return
	
	_shooting_logic()
	_start_shoot_timer()


func _start_shoot_timer(first_shot: bool = false) -> void:
	# edge case detetections
	if (
		not is_inside_tree()
		or cooldown_timer == null
		or turret_resource == null
		or turret_resource.cooldown <= 0.0
	):
		return
	
	# if its the first shot only waits 0.01 seconds instead of the cooldown after
	# the initial placement wait period
	if first_shot:
		cooldown_timer.start(FIRST_SHOT_TIMER_WAIT)
	else:
		cooldown_timer.start(turret_resource.cooldown)


func _stop_shoot_timer() -> void:
	if cooldown_timer:
		cooldown_timer.stop()
