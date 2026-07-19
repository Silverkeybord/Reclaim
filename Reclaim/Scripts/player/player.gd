class_name Player
extends CharacterBody3D

const PLACE_ANIMATION_KEY := "build_placed"

const WEAPON_MODE_INPUT := "1 - Weapon"
const BUILD_MODE_INPUT := "2 - Building"
const INSTALL_MODE_INPUT := "3 - Installation"
const BUILDING_INPUTS := "F - Change Builds
M2 - Pick up Builds
Scroll - Selection"
const INTERACT_INPUT := "E - Interact"

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
@export var shooting_timer : Timer
@export var arm_piviot : Node3D
@export var gun_piviot : Node3D
@export var hammmer_piviot : Node3D
@export var wrench_piviot : Node3D

@export_group("turrets")
@export var turret_holagram_scene : PackedScene
@export var turret_grid : Node3D
@export var selected_turret : String = ""
@export var selected_base : String = ""

@export_group("2d elements")
@export var build_overlay : Control
@export var build_label : Label
@export var input_tip : Label
@export var building_selection : CanvasLayer
@export var user_interface_animations : AnimationPlayer

var turret_holagram : Node3D

var can_shoot : bool = true
var weapon : Node3D
var weapon_name : String = "pistol"
var weapon_resource : WeaponData

var can_remove_build := true

var turrets : Dictionary


func _ready() -> void:
	# gives the player their starting weapon
	_set_new_weapon()
	Global.set_random_storage(true)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= Global.GRAVITY * delta
	else:
		velocity.y = 0.0
	
	if not Global.crafting_open:
		#basic movement
		var input_dir := Input.get_vector("left", "right", "forward", "back")
		var direction := (global_basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
		
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		
		if Input.is_action_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
	else:
		velocity = Vector3(0, velocity.y, 0)
	
	move_and_slide()


func _process(_delta: float) -> void:
	_shoot_control()
	_player_mode_handeling()
	_input_tip_updating()
	
	var ray_collider = aim_ray.get_collider()
	
	match Global.player_mode:
		Global.PLAYER_MODES.WEAPON:
			pass
		Global.PLAYER_MODES.BUILDING:
			_build_mode_handeling(ray_collider)
		Global.PLAYER_MODES.INSTALLING:
			pass
	
	if Global.player_mode != Global.PLAYER_MODES.BUILDING:
		_interaction_handeling(ray_collider)


func _input_tip_updating() -> void:
	var input_tip_output = []
	
	if Global.player_mode == Global.PLAYER_MODES.BUILDING:
		input_tip_output.append(BUILDING_INPUTS)
	
	if not Global.at_ship:
		if Global.player_mode != Global.PLAYER_MODES.WEAPON:
			input_tip_output.append(WEAPON_MODE_INPUT)
		
		if Global.player_mode != Global.PLAYER_MODES.BUILDING:
			input_tip_output.append(BUILD_MODE_INPUT)
		
		if Global.player_mode != Global.PLAYER_MODES.INSTALLING:
			input_tip_output.append(INSTALL_MODE_INPUT)
	
	if Global.player_mode != Global.PLAYER_MODES.BUILDING:
		input_tip_output.append(INTERACT_INPUT)
	
	var output_text : String = ""
	var formating_amount = input_tip_output.size()
	
	for x in input_tip_output:
		output_text += x
		formating_amount -= 1
		
		if formating_amount > 0:
			output_text += "
			"
	 
	input_tip.text = output_text


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


# handels the player changing modes
func _player_mode_handeling() -> void:
	if (
		Input.is_action_just_pressed("weapon_mode") and 
		not Global.player_mode == Global.PLAYER_MODES.WEAPON
	):
		Global.player_mode = Global.PLAYER_MODES.WEAPON
		_remove_holagram(true)
		toggle_player_mode_item(gun_piviot)
	
	if (
		Input.is_action_just_pressed("build_mode") and 
		not Global.at_ship and 
		not Global.player_mode == Global.PLAYER_MODES.BUILDING
	):
		Global.player_mode = Global.PLAYER_MODES.BUILDING
		building_selection.visible = true
		building_selection.load_selection()
		building_selection.set_process(true)
		turret_grid._toggle_build_mode(true)
		toggle_player_mode_item(hammmer_piviot)
	
	if (
		Input.is_action_just_pressed("install_mode") and 
		not Global.at_ship and
		not Global.player_mode == Global.PLAYER_MODES.INSTALLING
	):
		Global.player_mode = Global.PLAYER_MODES.INSTALLING
		_remove_holagram(true)
		toggle_player_mode_item(wrench_piviot)


# make all other items invisible and make the piviot visible
func toggle_player_mode_item(piviot : Node3D) -> void:
	gun_piviot.visible = false
	hammmer_piviot.visible = false
	wrench_piviot.visible = false
	
	piviot.visible = true


# BUILDING -------------------------------------------------------------------
# handels all build related logic from toggling modes and placement logic
func _build_mode_handeling(ray_collider : Node) -> void:
	var build_ray_collider = build_ray.get_collider()
	var current_build_selected : String
	
	# if there is no turret holagram create one and add
	if Global.player_mode == Global.PLAYER_MODES.BUILDING and not turret_holagram:
		gun_piviot.visible = false
		turret_holagram = turret_holagram_scene.instantiate()
		add_sibling(turret_holagram)
		interact_overlay.visible = false
	
	
	# changes the build mode to the next type
	if Input.is_action_just_pressed("change_build_mode"):
		var build_modes : int = Global.BUILD_MODES.size()
		Global.current_build_mode = (
			((Global.current_build_mode + 1) % build_modes) as Global.BUILD_MODES
			)
		building_selection.change_build_mode()
	
	
	# toggle visibility of the holagram if there are no turret or bases to be placed
	match Global.current_build_mode:
		Global.BUILD_MODES.TURRET:
			if selected_turret:
				turret_holagram.visible = false
				current_build_selected = selected_turret
				
		Global.BUILD_MODES.BASE:
			if selected_base:
				turret_holagram.visible = false
				current_build_selected = selected_base
	
	
	# snaps the holagram onto a turret slot if the slot is unlocked and toggles
	# 2D elements
	if _check_valid_placement(ray_collider) and current_build_selected:
		var prexisting_build := false
		
		# checks if there is a prexisting build there and if there is changes
		# the text to say replace instead of place
		match Global.current_build_mode:
			Global.BUILD_MODES.TURRET:
				turret_holagram.visible = true
				turret_holagram.global_position = (
					ray_collider.turret_origin_point.global_position
					)
				
				if ray_collider.turret:
					prexisting_build = true
			
			Global.BUILD_MODES.BASE:
				turret_holagram.visible = true
				turret_holagram.global_position = ray_collider.global_position
				
				# ray collider is the turret slot so just checks if there is a base or not
				if ray_collider.base:
					prexisting_build = true
		
		# sets the text of the overlay
		
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
	
	elif turret_holagram and current_build_selected:
		# puts the holagram where the player is looking but marks it invalid
		if aim_ray.is_colliding() and current_build_selected:
			turret_holagram.global_position = aim_ray.get_collision_point()
			turret_holagram.visible = true
			
		else:
			turret_holagram.visible = false
			
		
		turret_holagram.valid_position = false
		build_overlay.visible = false
	
	else:
		turret_holagram.visible = false
		build_overlay.visible = false
	
	
	# placement
	if Input.is_action_pressed("place") and current_build_selected:
		if (
		_check_valid_placement(ray_collider) and 
		global_position.distance_to(ray_collider.global_position) < BUILD_RANGE
			):
			var can_place := false
			
			user_interface_animations.play(PLACE_ANIMATION_KEY)
			
			match Global.current_build_mode:
				Global.BUILD_MODES.TURRET:
					if ray_collider.can_place_turret:
						if HelperFunctions.check_for_item(DataRegistry.items[selected_turret]):
							ray_collider.place_selected_turret(selected_turret)
							can_place = true
				
				Global.BUILD_MODES.BASE:
					if ray_collider.can_place_base:
						if HelperFunctions.check_for_item(DataRegistry.items[selected_base]):
							ray_collider.build_base(selected_base)
							can_place = true
			
			if can_place:
				building_selection.placed_build()
	
	
	# picking up builds
	if Input.is_action_just_pressed("pick_up_build"):
		if (
			can_remove_build and
			build_ray_collider and 
			global_position.distance_to(build_ray_collider.global_position) < BUILD_RANGE
				):
				
				can_remove_build = false
				
				build_ray_collider.pick_up()
				building_selection.load_selection()
				
				if build_ray_collider.build_type == Global.BUILD_TYPES.BASE:
					build_ray_collider.slot.base_removed()
				
				await get_tree().create_timer(REMOVE_BUILD_DELAY).timeout
				can_remove_build = true


# checkes if the current posiiton of the turret is valid to be placed
func _check_valid_placement(ray_collider : Node) -> bool:
	if (not ray_collider or 
		not ray_collider.is_in_group("turret_slots") or 
		not ray_collider.unlocked
		):
		
		return false
	
	match Global.current_build_mode:
		Global.BUILD_MODES.TURRET:
			if ray_collider.base:
				return true
			else:
				return false
		
		Global.BUILD_MODES.BASE:
			return true
	
	return false


# just removes the holagram when changing build modes and toggles when changing mode
func _remove_holagram(change_mode : bool = false) -> void:
	gun_piviot.visible = true
	if turret_holagram:
		turret_holagram.queue_free()
	build_overlay.visible = false
	
	if change_mode and not Global.at_ship:
		turret_grid._toggle_build_mode(false)


# WEAPONS CONTROL ------------------------------------------------------------
func _shoot_control() -> void:
	if (
		Global.player_mode != Global.PLAYER_MODES.WEAPON or 
		not weapon or 
		Global.crafting_open
		):
		
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
				if weapon_resource.get_critical():
					hit.hit(weapon_resource.damage * weapon_resource.critical_multiplier, true)
				else:
					hit.hit(weapon_resource.damage)
				
				hit_overlay.visible = true
				await get_tree().create_timer(HIT_OVERLAY_TIME).timeout
				hit_overlay.visible = false
				HelperFunctions.spawn_temp_sound(weapon_resource.hit_resource)
			
	else:
		# if nothing is hit, shoot to the end of the ray instead
		var forward_vector = -aim_ray.global_basis.z
		var max_distance = aim_ray.target_position.length()
		
		to = aim_ray.global_position + (forward_vector * max_distance)
	
	# draws the bullet trail from the weapon to the target point
	var from = weapon.bullet_spawn.global_position
	
	HelperFunctions.create_bullet_trail(from, to, DataRegistry.bullet_trail[weapon_name])
	HelperFunctions.spawn_temp_sound(weapon_resource.shoot_resource, from)


func _set_new_weapon() -> void:
	# gets the weapon node and its data from DataRegistry
	weapon = gun_piviot.get_child(GUN_CHILD_INDEX)
	weapon_resource = DataRegistry.weapon[weapon_name]
	
	shooting_timer.wait_time = weapon_resource.cool_down


func _on_shoot_timer_timeout() -> void:
	can_shoot = true


# PICKING UP DROPS -----------------------------------------------------------
func _on_pick_up_area_body_entered(body: Node3D) -> void:
	# starts pick up movement when a valid drop touches the pickup area
	if body in get_tree().get_nodes_in_group(DROPS_GROUP_NAME) and body.valid:
		body.player = self
		body.prime_pick_up()
