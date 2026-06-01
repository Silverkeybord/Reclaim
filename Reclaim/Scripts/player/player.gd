extends CharacterBody3D

const INTERACT_DISTANCE := 5
const TURRET_PLACEMENT_DISTANCE := 20

const GUN_CHILD_INDEX := 0
const ENEMY_METADATA_TAG := "enemy"
const DROPS_GROUP_NAME := "drops"
const HIT_OVERLAY_TIME := 0.05


@export_group("player stat")
@export var jump_velocity := 20.0
@export var move_speed := 14.0
@export var acceleration := 40

@export_group("in scene")
@export var interact_overlay : Control
@export var hit_overlay : Control
@export var aim_ray : RayCast3D
@export var gun_piviot : Node3D
@export var shooting_timer : Timer

@export_group("turrets")
@export var turret_holagram_scene : PackedScene
@export var place_overlay : Control

var turret_holagram : Node3D

var can_shoot : bool = true
var weapon : Node3D
var weapon_name : String = "pistol"
var weapon_resourse : Resource


func _ready() -> void:
	# gives the player their starting weapon
	_set_new_weapon()


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
	
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_released("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	
	move_and_slide()


func _process(_delta: float) -> void:
	_shoot_control()
	
	var ray_collider = aim_ray.get_collider()
	_build_mode_handeling(ray_collider)
	
	if Global.build_mode:
		return
	
	_interaction_handeling(ray_collider)


func _interaction_handeling(ray_collider : Node) -> void:
	# shows the interact ui when looking at something interactable
	if (ray_collider in get_tree().get_nodes_in_group("interactable") and 
		global_position.distance_to(ray_collider.global_position) < INTERACT_DISTANCE
		):
		interact_overlay.visible = true
		
		if Input.is_action_just_pressed("interact"):
			ray_collider.interact()
		
	else:
		interact_overlay.visible =  false


func _build_mode_handeling(ray_collider : Node) -> void:
	# toggles build mode and spawns/deletes the turret holagram
	if Input.is_action_just_pressed("build_mode") and not Global.at_ship:
		Global.build_mode = not Global.build_mode
		
		if Global.build_mode:
			gun_piviot.visible = false
			turret_holagram = turret_holagram_scene.instantiate()
			add_sibling(turret_holagram)
			interact_overlay.visible = false
			
		else:
			gun_piviot.visible = true
			if turret_holagram:
				turret_holagram.queue_free()
			place_overlay.visible = false
	
	
	if Global.build_mode:
		# snaps the holagram onto a turret slot if the slot is unlocked
		if ray_collider and ray_collider.is_in_group("turret_slots") and ray_collider.unlocked:
			turret_holagram.global_position = ray_collider.turret_origin_point.global_position
			turret_holagram.valid_position = true
			place_overlay.visible = true
			
			if Input.is_action_pressed("place"):
				ray_collider.current_turret = "basic" # TEMPERORY
				ray_collider.place_selected_turret()
			
		else:
			# puts the holagram where the player is looking but marks it invalid
			turret_holagram.global_position = aim_ray.get_collision_point()
			turret_holagram.valid_position = false
			place_overlay.visible = false


# WEAPONS CONTROL ------------------------------------------------------------
func _shoot_control() -> void:
	if Global.build_mode or not weapon:
		return
	
	if Input.is_action_pressed("shoot") and can_shoot:
		can_shoot = false
		shooting_timer.start()
		_shoot()


func _shoot() -> void:
	var to : Vector3
	if aim_ray.is_colliding():
		to = aim_ray.get_collision_point()
		
		var hit = aim_ray.get_collider()
		if hit.has_meta(ENEMY_METADATA_TAG):
			# damages enemies and flashes the hit overlay
			hit.hit(weapon_resourse.damage)
			hit_overlay.visible = true
			await get_tree().create_timer(HIT_OVERLAY_TIME).timeout
			hit_overlay.visible = false
			
	else:
		# if nothing is hit, shoot to the end of the ray instead
		var forward_vector = -aim_ray.global_basis.z
		var max_distance = aim_ray.target_position.length()
		
		to = aim_ray.global_position + (forward_vector * max_distance)
	
	# draws the bullet trail from the weapon to the target point
	var from = weapon.bullet_spawn.global_position
	
	Global.create_bullet_trail(from, to, GameData.bullet_trail[weapon_name])


func _set_new_weapon() -> void:
	# gets the weapon node and its data from gamedata
	weapon = gun_piviot.get_child(GUN_CHILD_INDEX)
	weapon_resourse = GameData.weapon[weapon_name]
	
	shooting_timer.wait_time = weapon_resourse.cool_down


func _on_shoot_timer_timeout() -> void:
	can_shoot = true


func _on_pick_up_area_body_entered(body: Node3D) -> void:
	# starts pick up movement when a valid drop touches the pickup area
	if body in get_tree().get_nodes_in_group(DROPS_GROUP_NAME) and body.valid:
		body.player = self
		body.pick_up()
