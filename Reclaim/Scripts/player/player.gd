extends CharacterBody3D

const INTERACT_DISTANCE := 5
const BUILD_RANGE := 25

const GUN_CHILD_INDEX := 0
const REMOVE_BUILD_DELAY := 0.1
const HIT_OVERLAY_TIME := 0.08
const ENEMY_METADATA_TAG := "enemy"
const DROPS_GROUP_NAME := "drops"
const PICK_UP_TEXT := "CLICK TO PICK UP"
const PLACE_TEXT := "CLICK TO PLACE"
const REPLACE_TEXT := "CLICK TO REPLACE"
const MOVE_CLOSER_TEXT := "MOVE CLOSER"

@export_group("player stat")
@export var jump_velocity := 20.0
@export var move_speed := 14.0

@export_group("in scene")
@export var interact_overlay : Control
@export var hit_overlay : Control
@export var aim_ray : RayCast3D
@export var build_ray : RayCast3D
@export var gun_piviot : Node3D
@export var shooting_timer : Timer

@export_group("turrets")
@export var turret_holagram_scene : PackedScene
@export var turret_grid : Node3D

@export_group("2d elements")
@export var build_overlay : Control
@export var build_label : Label

var turret_holagram : Node3D

var can_shoot : bool = true
var weapon : Node3D
var weapon_name : String = "pistol"
var weapon_resourse : Resource

var selected_turret : String = "single"
var selected_base : String = "plate"

var can_remove_build := true


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
	
	if not Global.build_mode:
		_interaction_handeling(ray_collider)


# for all interactions that toggles a ui indicator that you can interact
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


# handels all build related logic from toggling modes and placement logic
func _build_mode_handeling(ray_collider : Node) -> void:
	var build_ray_collider = build_ray.get_collider()
	
	if Global.at_ship:
		return
	
	
	# toggles build mode and spawns/deletes the turret holagram
	if Input.is_action_just_pressed("build_mode"):
		Global.build_mode = not Global.build_mode
		
		turret_grid._toggle_build_mode(Global.build_mode)
		
		if Global.build_mode and not Global.picking_up_builds:
			gun_piviot.visible = false
			turret_holagram = turret_holagram_scene.instantiate()
			add_sibling(turret_holagram)
			interact_overlay.visible = false
			
		else:
			Global.picking_up_builds = false
			gun_piviot.visible = true
			if turret_holagram:
				turret_holagram.queue_free()
			build_overlay.visible = false
	
	
		# changes to the next build mode
	
	
	if not Global.build_mode:
		return
	
	
	# changes the build mode to the next type
	if Input.is_action_just_pressed("change_build_mode"):
		var build_modes : int = Global.BUILD_MODES.size()
		Global.current_build_mode = (
			((Global.current_build_mode + 1) % build_modes) as Global.BUILD_MODES
			)
	
	
	# toggles picking up when in build mode
	if Input.is_action_just_pressed("pick_up_build_toggle"):
		Global.picking_up_builds = not Global.picking_up_builds
		
		if turret_holagram:
			turret_holagram.visible = not Global.picking_up_builds
		
		
		if Global.picking_up_builds:
			build_label.text = PICK_UP_TEXT
		else:
			build_label.text = PLACE_TEXT
	
	
	# snaps the holagram onto a turret slot if the slot is unlocked and toggles
	# 2D elements
	if not Global.picking_up_builds:
		if _check_valid_placement(ray_collider):
			var prexisting_build := false
			
			# checks if there is a prexisting build there and if there is changes
			# the text to say replace instead of place
			match Global.current_build_mode:
				Global.BUILD_MODES.TURRET:
					turret_holagram.global_position = (
						ray_collider.turret_origin_point.global_position
						)
					
					if ray_collider.turret:
						prexisting_build = true
				
				Global.BUILD_MODES.BASE:
					turret_holagram.global_position = ray_collider.global_position
					
					if ray_collider.base:
						prexisting_build = true
			
			
			
			if global_position.distance_to(ray_collider.global_position) < BUILD_RANGE:
				turret_holagram.valid_position = true
				if prexisting_build:
					build_label.text = REPLACE_TEXT
				else:
					build_label.text = PLACE_TEXT
				
			else:
				build_label.text = MOVE_CLOSER_TEXT
				turret_holagram.valid_position = false
			
			
			build_overlay.visible = true
		
		elif turret_holagram:
			# puts the holagram where the player is looking but marks it invalid
			turret_holagram.global_position = aim_ray.get_collision_point()
			turret_holagram.valid_position = false
			build_overlay.visible = false
		
	else:
		if build_ray_collider:
			build_overlay.visible = true
		else:
			build_overlay.visible = false
	
	
	if Input.is_action_pressed("place_or_remove"):
	
		if Global.picking_up_builds:
		
			if (
			can_remove_build and
			build_ray_collider and 
			global_position.distance_to(build_ray_collider.global_position) < BUILD_RANGE
				):
				
				can_remove_build = false
				
				build_ray_collider.pick_up()
				
				if build_ray_collider.build_type == Global.BUILD_TYPES.BASE:
					build_ray_collider.slot.base_removed()
				
				await get_tree().create_timer(REMOVE_BUILD_DELAY).timeout
				can_remove_build = true
			
		else:
			if (
			_check_valid_placement(ray_collider) and 
			global_position.distance_to(ray_collider.global_position) < BUILD_RANGE
				):
				
				match Global.current_build_mode:
					Global.BUILD_MODES.TURRET:
						ray_collider.place_selected_turret(selected_turret)
					
					Global.BUILD_MODES.BASE:
						ray_collider.build_base(selected_base)


# checkes if the current posiiton of the turret is valid to be placed
func _check_valid_placement(ray_collider : Node) -> bool:
	if (not ray_collider or 
		not ray_collider.is_in_group("turret_slots") or 
		not ray_collider.unlocked
		):
		
		return false
	
	if Global.picking_up_builds:
		return true
	
	match Global.current_build_mode:
		Global.BUILD_MODES.TURRET:
			if ray_collider.base:
				return true
			else:
				return false
		
		Global.BUILD_MODES.BASE:
			return true
	
	return false


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
		if hit:
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
	
	Global.create_bullet_trail(from, to, DataRegistry.bullet_trail[weapon_name])


func _set_new_weapon() -> void:
	# gets the weapon node and its data from DataRegistry
	weapon = gun_piviot.get_child(GUN_CHILD_INDEX)
	weapon_resourse = DataRegistry.weapon[weapon_name]
	
	shooting_timer.wait_time = weapon_resourse.cool_down


func _on_shoot_timer_timeout() -> void:
	can_shoot = true


func _on_pick_up_area_body_entered(body: Node3D) -> void:
	# starts pick up movement when a valid drop touches the pickup area
	if body in get_tree().get_nodes_in_group(DROPS_GROUP_NAME) and body.valid:
		body.player = self
		body.prime_pick_up()
