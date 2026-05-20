extends turret_basics

@export var in_range_enemies := []

@export_group("in scene")
@export var turret_piviot_point : Node3D
@export var turret_gun : Node3D
@export var bullet_spawn : Marker3D
@export var cooldown_timer : Timer

@export_group("turret_stats")
@export var turret_range := 25.0
@export var cooldown := 0.2
@export var damage := 1

var connected_enemies := []
var on_cooldown = false


func _ready() -> void:
	cooldown_timer.wait_time = cooldown


func _process(_delta: float) -> void:
	_shooting_logic()


# TARGETING LOGIC ------------------------------------------------------------
func _on_turret_range_area_body_entered(body: Node3D) -> void:
	if not is_instance_valid(body):
		return
	
	if body not in in_range_enemies:
		in_range_enemies.append(body)
		if body not in connected_enemies:
			connected_enemies.append(body)
			body.tree_exiting.connect(_enemy_died.bind(body))


func _on_turret_range_area_body_exited(body: Node3D) -> void:
	if not is_instance_valid(body):
		return
	
	in_range_enemies.erase(body)


func _enemy_died(enemy: Node) -> void:
	in_range_enemies.erase(enemy)


func _get_target():
	var target = null
	
	if not in_range_enemies:
		return target
	
	for enemy in in_range_enemies:
		if target:
			if position.distance_to(enemy.global_position) < position.distance_to(target.global_position):
				target = enemy
		else:
			target = enemy
	
	return target


# SHOOTING LOGIC --------------------------------------------------------------
func _shooting_logic() -> void:
	var target = _get_target()
	
	if target:
		turret_piviot_point.look_at(target.global_position)
		
		if not on_cooldown:
			on_cooldown = true
			cooldown_timer.start()
			
			target.hp -= damage
			target.check_dead()
			
			# creates a new bullet trail bassed on the bullet spawn and target pos
			var new_bullet_trail = bullet_trail_scene.instantiate()
			add_sibling(new_bullet_trail)
			new_bullet_trail.create_bullet_trail(bullet_spawn.global_position,
												target.global_position)


func _on_cool_down_timer_timeout() -> void:
	on_cooldown = false
