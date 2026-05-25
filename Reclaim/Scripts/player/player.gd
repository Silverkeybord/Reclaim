extends CharacterBody3D

const INTERACT_DISTANCE := 5
const TURRET_PLACEMENT_DISTANCE := 20

@export_group("player stat")
@export var jump_velocity := 20.0
@export var move_speed := 14.0
@export var acceleration := 40

@export_group("in scene")
@export var interact_overlay : Control
@export var sight_ray : RayCast3D

@export_group("turrets")
@export var turret_holagram_scene : PackedScene
@export var place_overlay : Control


var turret_holagram : Node3D


func _physics_process(delta: float) -> void:
	#basic movement
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (global_basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	if not is_on_floor():
		velocity.y -= Global.GRAVITY * delta
	else:
		velocity.y = 0.0
	
	
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_released("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	
	move_and_slide()


func _process(_delta: float) -> void:
	
	
	var ray_collider = sight_ray.get_collider()
	_build_mode_handeling(ray_collider)
	
	if Global.build_mode:
		return
	
	_interaction_handeling(ray_collider)


func _interaction_handeling(ray_collider : Node) -> void:
	if (ray_collider in get_tree().get_nodes_in_group("interactable") and 
		global_position.distance_to(ray_collider.global_position) < INTERACT_DISTANCE
		):
		interact_overlay.visible = true
		
		if Input.is_action_just_pressed("interact"):
			ray_collider.interact()
		
	else:
		interact_overlay.visible =  false


func _build_mode_handeling(ray_collider : Node) -> void:
	if Input.is_action_just_pressed("build_mode") and not Global.at_ship:
		Global.build_mode = not Global.build_mode
		
		if Global.build_mode:
			turret_holagram = turret_holagram_scene.instantiate()
			add_sibling(turret_holagram)
			interact_overlay.visible = false
			
		else:
			if turret_holagram:
				turret_holagram.queue_free()
			place_overlay.visible = false
	
	
	if Global.build_mode:
		if ray_collider and ray_collider.is_in_group("turret_slots") and ray_collider.unlocked:
			turret_holagram.global_position = ray_collider.turret_origin_point.global_position
			turret_holagram.valid_position = true
			place_overlay.visible = true
			
			if Input.is_action_pressed("place"):
				ray_collider.current_turret = "basic"
				ray_collider.place_selected_turret()
				#Global.build_mode = false
				#turret_holagram.queue_free()
				#place_overlay.visible = false
			
		else:
			turret_holagram.global_position = sight_ray.get_collision_point()
			turret_holagram.valid_position = false
			place_overlay.visible = false
	
	
