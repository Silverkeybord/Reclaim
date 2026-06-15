class_name turret_basics

extends builds

enum SHOOTING_METHODS {
	FIRST,
	LAST,
	STRONG,
	RANDOM,
}

const FIRST_SHOT_TIMER_WAIT := 0.01

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
# when godot detects that the varible will be changed from the timer ending
# and settings teh value to false it runs the code underneath value is the 
# value its going to be set to then some basic logic is run to optimise code
@export var place_cooldown_active := true:
	set(value):
		place_cooldown_active = value
		
		if place_cooldown_active:
			_stop_shoot_timer()
		else:
			_start_shoot_timer(true)


func _ready() -> void:
	_set_new_turret("basic") # TEMP
	cooldown_timer.wait_time = turret_resourse.cooldown
	cooldown_timer.one_shot = true
	
	if not place_cooldown_active:
		_start_shoot_timer(true)


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
	
	target.hit(turret_resourse.damage)
	
	# Creates a bullet trail using the target position before the enemy is freed.
	Global.create_bullet_trail(bullet_spawn.global_position, target_position)


func _on_cool_down_timer_timeout() -> void:
	if place_cooldown_active:
		return
	
	_shooting_logic()
	_start_shoot_timer()


func _start_shoot_timer(first_shot := false) -> void:
	# edge case detetections
	if not is_inside_tree() or cooldown_timer == null or turret_resourse == null:
		return
	
	# if its the first shot only waits 0.01 seconds instead of the cooldown after
	# the initial placement wait period
	if first_shot:
		cooldown_timer.start(FIRST_SHOT_TIMER_WAIT)
	else:
		cooldown_timer.start(turret_resourse.cooldown)


func _stop_shoot_timer() -> void:
	if cooldown_timer:
		cooldown_timer.stop()
