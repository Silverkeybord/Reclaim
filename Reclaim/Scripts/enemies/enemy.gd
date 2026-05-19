class_name base_enemy

extends CharacterBody3D

@export var hp := 20
@export var speed := 10
@export var type := ""
@export var size := 1

@export var extraction_pod : Node3D


func _process(delta: float) -> void:
	var target = extraction_pod
	
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed 
	
	if not is_on_floor():
		velocity.y -= Global.GRAVITY * delta
	else:
		velocity.y = 0.0
	
	move_and_slide()


func check_dead() -> void:
	if hp <= 0:
		_die()


func _die() -> void:
	queue_free()
