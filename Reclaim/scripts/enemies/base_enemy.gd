class_name BaseEnemy
extends CharacterBody3D

# Signals ----------------------------------------------------------------------
signal died(enemy: BaseEnemy)

# Constants --------------------------------------------------------------------
const ENEMY_LAYER : int = 4
const NONE_TYPE_DROP : StringName = &"none"
const LOAD_BUFFER : float = 0.5
const SIZE_BASE_STAT_FACTOR : float = 0.5
const GRAVITY : float = 80.0

const PROP_COLLISION_LAYER : StringName = &"collision_layer"
const PROP_COLLISION_MASK : StringName = &"collision_mask"
const PROP_DISABLED : StringName = &"disabled"
const PROP_ITEM_DATA : StringName = &"item_data"

# Exports ----------------------------------------------------------------------
@export var valid : bool = false
@export var enemy_resource : EnemyData
@export var extraction_pod : Node3D
@export var sector_shield : SectorShield
@export var drops_scene : PackedScene

@export_group("Enemy Stats")
@export var health : float
@export var is_commander : bool = false
@export var size : float = 1.0

@export_group("In Scene")
@export var collision_shape : CollisionShape3D
@export var attack_timer : Timer

# Variables --------------------------------------------------------------------
var is_dead : bool = false
var damage : int = 0
var speed : float = 0.0
var can_attack : bool = false


func _physics_process(delta: float) -> void:
	if not can_attack:
		movement(delta)


# Movement ---------------------------------------------------------------------
func movement(delta: float) -> void:
	if extraction_pod == null or is_dead:
		return
	
	var target_pos: Vector3 = extraction_pod.global_position
	var move_dir: Vector3 = (target_pos - global_position)
	move_dir.y = 0.0
	
	if not move_dir.is_zero_approx():
		move_dir = move_dir.normalized()
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	
	move_and_slide()


# Setup & Initialization -------------------------------------------------------
func finish_loading() -> void:
	set_process(false)
	set_physics_process(false)
	
	var tree := get_tree()
	if tree:
		await tree.create_timer(LOAD_BUFFER).timeout
	
	if is_dead or not is_inside_tree():
		return
	
	global_position.y += size / 2.0
	
	set_collision_layer_value(ENEMY_LAYER, true)
	set_process(true)
	set_physics_process(true)
	
	Global.enemies += 1
	
	if enemy_resource:
		var mult: float = 1.0 + ((size - 1.0) / SIZE_BASE_STAT_FACTOR)
		health = roundf(enemy_resource.health * mult)
		damage = int(roundf(enemy_resource.damage * mult))
		speed = enemy_resource.speed
		if attack_timer:
			attack_timer.wait_time = enemy_resource.attack_interval
	
	valid = true


# Health & Combat --------------------------------------------------------------
func hit(hit_damage: float, crit: bool = false) -> void:
	health -= hit_damage
	HelperFunctions.create_damage_indicator(global_position, hit_damage, crit)
	if health <= 0.0 and not is_dead:
		_die()


func _die() -> void:
	is_dead = true
	valid = false
	died.emit(self)
	
	_spawn_drops()
	
	set_process(false)
	set_physics_process(false)
	set_deferred(PROP_COLLISION_LAYER, 0)
	set_deferred(PROP_COLLISION_MASK, 0)
	
	if collision_shape:
		collision_shape.set_deferred(PROP_DISABLED, true)
	
	Global.enemies = maxi(0, Global.enemies - 1)
	
	_queue_free_after_physics.call_deferred()


func _queue_free_after_physics() -> void:
	var tree := get_tree()
	if tree:
		await tree.physics_frame
		if get_tree():
			await get_tree().physics_frame
	queue_free()


# Drops ------------------------------------------------------------------------
func _spawn_drops() -> void:
	if enemy_resource == null or drops_scene == null:
		return
	
	var drop_count: int = randi_range(enemy_resource.min_drops, enemy_resource.max_drops)
	for x in range(drop_count):
		var drop_type: Resource = _get_drop_type_resource()
		if drop_type:
			var new_drop := drops_scene.instantiate() as RigidBody3D
			if new_drop:
				new_drop.set(PROP_ITEM_DATA, drop_type)
				add_sibling(new_drop)
				new_drop.global_position = global_position


func _get_drop_type_resource() -> ItemData:
	if enemy_resource == null or enemy_resource.drop_table.is_empty():
		return null
	
	var total_weight: float = 0.0
	for drop_info: DropWeight in enemy_resource.drop_table:
		if drop_info:
			total_weight += drop_info.weight
	
	if total_weight <= 0.0:
		return null
	
	var roll: float = randf() * total_weight
	for drop_info: DropWeight in enemy_resource.drop_table:
		if drop_info == null:
			continue
		
		roll -= drop_info.weight
		if roll <= 0.0:
			if drop_info.drop == null or drop_info.drop.key == NONE_TYPE_DROP:
				return null
			
			var item_key: String = drop_info.drop.key
			if DataRegistry.items.has(item_key):
				return DataRegistry.items[item_key]
			return null
	
	return null


# Attack Logic -----------------------------------------------------------------
func start_attacking() -> void:
	if attack_timer:
		attack_timer.start()
	_attack()


func stop_attacking() -> void:
	if attack_timer:
		attack_timer.stop()


func _attack() -> void:
	if sector_shield and sector_shield.has_method(&"hit_shield"):
		sector_shield.hit_shield(damage)
	
	if attack_timer:
		attack_timer.start()


func _on_attack_timer_timeout() -> void:
	if can_attack:
		_attack()
