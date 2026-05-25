class_name base_enemy

extends CharacterBody3D
## Moves towards the extraction pod and handles enemy death.

signal died(enemy: base_enemy)

const LOAD_BUFFER : float = 0.5

@export var valid := false

@export var hp := 20
@export var speed := 5
@export var type := ""
@export var size := 1

@export var extraction_pod : Node3D
@export var collision_shape: CollisionShape3D

var is_dead := false

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
	await get_tree().create_timer(LOAD_BUFFER).timeout
	
	# edge case
	if is_dead:
		return
	
	Global.enemies += 1
	
	valid = true


func check_dead() -> void:
	if hp <= 0 and not is_dead:
		_die()


func _die() -> void:
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
