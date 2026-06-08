class_name base_enemy

extends CharacterBody3D
## Moves towards the extraction pod and handles enemy death.

signal died(enemy: base_enemy)

const DIRT_TYPE_FALLBACK : String = "dirt"
const LOAD_BUFFER : float = 0.5
const SIZE_BASE_STAT_FACTOR : float = 0.5

@export var valid := false

@export var enemy_resourse : EnemyData
@export var is_commander : bool = false
@export var size : float

@export var extraction_pod : Node3D
@export var collision_shape: CollisionShape3D

@export var drops_scene : PackedScene

var is_dead := false
var hp : int
var damage : int
var speed : float

var drops : Dictionary


func _physics_process(_delta: float) -> void:
	if extraction_pod == null or is_dead:
		return
	
	var target = extraction_pod
	
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed 
	
	if not is_on_floor():
		velocity.y -= Global.GRAVITY
	else:
		velocity.y = 0.0
	
	move_and_slide()


func fin_loading() -> void:
	set_process(false)
	set_physics_process(false)
	
	# so turrets dont target it when its is instianted at 0, 0, 0
	await get_tree().create_timer(LOAD_BUFFER).timeout
	
	set_process(true)
	set_physics_process(true)
	
	# edge case
	if is_dead:
		return
	
	# Gets the drops that will drop
	for x in enemy_resourse.drop_table:
		if enemy_resourse.drop_table[x] > 0:
			drops[x] = enemy_resourse.drop_table[x]
	
	Global.enemies += 1
	
	# sets stats
	# mulitplys the base stats by their size by half
	var mult = 1 + ((size - 1) / SIZE_BASE_STAT_FACTOR)
	hp = round(enemy_resourse.hp * mult)
	damage = round(enemy_resourse.damage * mult)
	speed = enemy_resourse.speed
	
	valid = true


func hit(hit_damage : int) -> void:
	hp -= hit_damage
	Global.create_damage_indicator(global_position, hit_damage)
	if hp <= 0 and not is_dead:
		_die()


func _die() -> void:
	_spawn_drops()
	
	is_dead = true
	valid = false
	died.emit(self)
	
	set_process(false)
	set_physics_process(false)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	if Global.enemies <= 0:
		Global.enemies = 0
	else:
		Global.enemies -= 1
	
	_queue_free_after_physics.call_deferred()


# waits 2 physics frames just for safety to make sure turrets can remove the connection
func _queue_free_after_physics() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	queue_free()


func _spawn_drops() -> void:
	for x in range(randi_range(enemy_resourse.min_drops, enemy_resourse.max_drops)):
		var new_drop = drops_scene.instantiate()
		new_drop.drop_resourse = _get_drop_type_resourse()
		add_sibling(new_drop)
		new_drop.global_position = global_position


func _get_drop_type_resourse():
	
	var value = randf()
	var drop_weight : float = 0.0
	
	for x in drops:
		drop_weight += drops[x] / Global.PROBABLITY_DIVIDE_CONSTANT
		if drop_weight > value:
			return GameData.drops[x]
	
	print("invalid weights returning dirt from enemy : ", enemy_resourse.key)
	return GameData.drops[DIRT_TYPE_FALLBACK]
