class_name turret_basics

extends Node3D

enum SHOOTING_METHODS {
	FIRST,
	LAST,
	STRONG,
	RANDOM,
}

@export var turret_shooting_type := SHOOTING_METHODS.FIRST

@export_group("in scene")
@export var turret_piviot_point : Node3D
@export var turret_gun : Node3D
@export var bullet_spawn : Marker3D
@export var cooldown_timer : Timer
@export var turret_range_area : TurretRangeArea
@export var turret_range_coll : CollisionShape3D

@export_group("turret_stats")
@export var turret_resourse : Resource
@export var place_cooldown_active := true

var on_cooldown = false


func _ready() -> void:
	_set_new_turret("basic")
	cooldown_timer.wait_time = turret_resourse.cooldown


func _process(_delta: float) -> void:
	if not place_cooldown_active:
		_shooting_logic()


func _set_new_turret(key : String) -> void:
	turret_resourse = GameData.turrets[key]


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
	
	target.hit(turret_resourse.damage)
	
	# Creates a bullet trail using the target position before the enemy is freed.
	Global.create_bullet_trail(bullet_spawn.global_position, target_position)


func _on_cool_down_timer_timeout() -> void:
	on_cooldown = false
