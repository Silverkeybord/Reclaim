extends turret_basics

@export_group("in scene")
@export var turret_piviot_point : Node3D
@export var turret_gun : Node3D
@export var bullet_spawn : Marker3D
@export var cooldown_timer : Timer
@export var turret_range_area : TurretRangeArea

@export_group("turret_stats")
@export var turret_range := 25.0
@export var cooldown := 0.2
@export var damage := 1
@export var place_cooldown_active := true

var on_cooldown = false


func _ready() -> void:
	cooldown_timer.wait_time = cooldown


func _process(_delta: float) -> void:
	
	if not place_cooldown_active:
		_shooting_logic()


# SHOOTING LOGIC --------------------------------------------------------------
func _shooting_logic() -> void:
	if turret_range_area == null:
		return
	
	var target = turret_range_area.get_target()
	
	if (
		target == null
		or not is_instance_valid(target)
		or not target.valid
		or target.is_dead
		or target.is_queued_for_deletion()
	):
		return
	
	var target_position : Vector3 = target.global_position
	turret_piviot_point.look_at(target_position)
		
	if on_cooldown:
		return
	
	on_cooldown = true
	cooldown_timer.start()
	
	target.hp -= damage
	target.check_dead()
	
	# Creates a bullet trail using the target position before the enemy is freed.
	Global.create_bullet_trail(bullet_spawn.global_position, target_position)


func _on_cool_down_timer_timeout() -> void:
	on_cooldown = false
