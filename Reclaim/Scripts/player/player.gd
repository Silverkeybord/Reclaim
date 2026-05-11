extends CharacterBody3D

const INTERACT_DISTANCE := 5

@export_group("player stat")
@export var jump_velocity := 20.0
@export var move_speed := 14.0
@export var gravity := 40.0
@export var acceleration := 40

@export_group("in scene")
@export var interact_overlay : Control
@export var sight_ray : RayCast3D
 

func _physics_process(delta: float) -> void:
	#basic movement
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (global_basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	
	
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_released("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	
	move_and_slide()


func _process(_delta: float) -> void:
	
	_interaction_handeling()


func _interaction_handeling() -> void:
	var ray_collider = sight_ray.get_collider()
	
	if (ray_collider in get_tree().get_nodes_in_group("interactable") and 
		global_position.distance_to(ray_collider.global_position) < INTERACT_DISTANCE
		):
		interact_overlay.visible = true
		
		if Input.is_action_just_pressed("interact"):
			ray_collider.interact()
		
	else:
		interact_overlay.visible=  false
