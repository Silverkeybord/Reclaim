class_name base_enemy

extends CharacterBody3D
## Moves towards the extraction pod and handles enemy death.

signal died(enemy: base_enemy)

const LOAD_BUFFER : float = 0.5

@export var valid := false

@export var enemy_resourse : Resource = GameData.enemies["basic"] # TEMP
@export var size : float

@export var extraction_pod : Node3D
@export var collision_shape: CollisionShape3D

@export var drops_scene : PackedScene

var is_dead := false
var hp : int
var damage : int
var speed : int


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
	
	Global.enemies += 1
	
	# sets stats
	hp = enemy_resourse.hp * size
	damage = enemy_resourse.damage * size
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
	for x in range(5):
		var new_drop = drops_scene.instantiate()
		get_tree().root.add_child(new_drop)
		new_drop.global_position = global_position
