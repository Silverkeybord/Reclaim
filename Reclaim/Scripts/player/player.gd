class_name Player
extends CharacterBody3D

# =============================================================================
# CONSTANTS
# =============================================================================

# Input Action Names
const ACTION_LEFT: StringName = &"left"
const ACTION_RIGHT: StringName = &"right"
const ACTION_FORWARD: StringName = &"forward"
const ACTION_BACK: StringName = &"back"
const ACTION_JUMP: StringName = &"jump"
const ACTION_SHOOT: StringName = &"shoot"
const ACTION_INTERACT: StringName = &"interact"
const ACTION_WEAPON_MODE: StringName = &"weapon_mode"
const ACTION_BUILD_MODE: StringName = &"build_mode"
# const ACTION_INSTALL_MODE: StringName = &"install_mode" # FUTURE DEV: Installation mode disabled
const ACTION_CHANGE_BUILD_VIEW: StringName = &"change_build_view"
const ACTION_PLACE: StringName = &"place"
const ACTION_PICK_UP_BUILD: StringName = &"pick_up_build"

# Groups & Metadata Tags
const GROUP_INTERACTABLE: StringName = &"interactable"
const GROUP_DROPS: StringName = &"drops"
const GROUP_TURRET_SLOTS: StringName = &"turret_slots"
const ENEMY_METADATA_TAG: StringName = &"enemy"

# Dynamic Property & Method String Names
const PROP_VALID: StringName = &"valid"
const PROP_PLAYER: StringName = &"player"
const PROP_BULLET_SPAWN: StringName = &"bullet_spawn"
const METHOD_INTERACT: StringName = &"interact"
const METHOD_HIT: StringName = &"hit"
const METHOD_TOGGLE_BUILD_MODE: StringName = &"_toggle_build_mode"
const METHOD_PRIME_PICK_UP: StringName = &"prime_pick_up"

# Building Related Properties
const BUILD_PROP_ORIGIN_POINT: StringName = &"turret_origin_point"
const BUILD_PROP_TURRET: StringName = &"turret"
const BUILD_PROP_BASE: StringName = &"base"
const BUILD_PROP_SLOT: StringName = &"slot"
const BUILD_PROP_UNLOCKED: StringName = &"unlocked"
const BUILD_PROP_BUILD_TYPE: StringName = &"build_type"
const BUILD_PROP_CAN_PLACE_TURRET: StringName = &"can_place_turret"
const BUILD_PROP_CAN_PLACE_BASE: StringName = &"can_place_base"
const BUILD_PROP_CURRENT_ITEM_TYPE: StringName = &"current_item_type"

# Node Methods
const METHOD_PICK_UP: StringName = &"pick_up"
const METHOD_BASE_REMOVED: StringName = &"base_removed"
const METHOD_PLACE_TURRET: StringName = &"place_selected_turret"
const METHOD_BUILD_BASE: StringName = &"build_base"

# Animation Keys & Defaults
const PLACE_ANIMATION_KEY: StringName = &"build_placed"
const DEFAULT_WEAPON_NAME: String = "pistol"

# UI Display Strings
const WEAPON_MODE_INPUT: String = "1 - Weapon"
const BUILD_MODE_INPUT: String = "2 - Building"
# const INSTALL_MODE_INPUT: String = "3 - Installation" # FUTURE DEV: Installation mode disabled
const BUILDING_INPUTS: String = "M2 - Pick up Builds\nScroll - Selection\nF - Build View"
const INTERACT_INPUT: String = "E - Interact"
const SHOW_PINNED_INPUT: String = "TAB - Pinned"
const PAUSE_INPUT: String = "esc - Pause"

const PICK_UP_TEXT: String = "CLICK TO PICK UP"
const PLACE_TEXT: String = "CLICK TO PLACE"
const REPLACE_TEXT: String = "CLICK TO REPLACE"
const MOVE_CLOSER_TEXT: String = "MOVE CLOSER"

# Physics & Interaction Parameters
const GRAVITY: float = 40.0
const INTERACT_DISTANCE: float = 5.0
const BUILD_RANGE: float = 25.0
const GUN_CHILD_INDEX: int = 0
const REMOVE_BUILD_DELAY: float = 0.1
const HIT_OVERLAY_TIME: float = 0.08
const PICK_UP_COOLDOWN: float = 2.0
const ZERO_FLOAT: float = 0.0
const BUILD_RAY_LENGTH: float = 150.0


# =============================================================================
# EXPORTS
# =============================================================================
@export_group("Player Stats")
@export var jump_velocity: float = 20.0
@export var move_speed: float = 16.0
@export var in_shield: bool = false

@export_group("In Scene References")
@export var interact_overlay: Control
@export var hit_overlay: Control
@export var aim_ray: RayCast3D
@export var build_ray: RayCast3D
@export var shooting_timer: Timer
@export var pick_up_area: Area3D
@export var normal_camera: Camera3D
@export var reticle_root: Control

@export_subgroup("Pivots")
@export var arm_pivot: Node3D
@export var gun_pivot: Node3D
@export var hammer_pivot: Node3D
@export var wrench_pivot: Node3D

@export_group("Turrets & Building")
@export var turret_holagram_scene: PackedScene
@export var turret_grid: Node3D
@export var selected_build: String = ""
@export var build_camera: Camera3D
@export var top_down_build_ray: RayCast3D
@export var top_down_shader: ColorRect

@export_group("2D UI Elements")
@export var canvas_root: CanvasLayer
@export var build_overlay: Control
@export var build_label: Label
@export var action_bar: Label
@export var building_selection: BuildSelection
@export var user_interface_animations: AnimationPlayer
@export var item_notif_controller: ItemNotifController
@export var fps_lable: Label
@export var action_bar_panel: PanelContainer


# =============================================================================
# VARIABLES
# =============================================================================
var turret_holagram: Node3D = null
var can_shoot: bool = true
var weapon: Node3D = null
var weapon_name: String = DEFAULT_WEAPON_NAME
var weapon_resource: WeaponData = null
var can_remove_build: bool = true


func _ready() -> void:
	Global.set_random_storage()
	_set_new_weapon()


## Handles gravity, movement input, and jumping every physics frame.
func _physics_process(delta: float) -> void:
	if Global.major_animation_playing:
		return
	
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = ZERO_FLOAT
	
	if not Global.ui_open and not Global.top_down_build_view:
		var input_dir := Input.get_vector(
			ACTION_LEFT,
			ACTION_RIGHT,
			ACTION_FORWARD,
			ACTION_BACK
		)
		
		var direction := (
			global_basis * Vector3(input_dir.x, ZERO_FLOAT, input_dir.y)
		).normalized()
		
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		
		if Input.is_action_pressed(ACTION_JUMP) and is_on_floor():
			velocity.y = jump_velocity
	else:
		velocity = Vector3(ZERO_FLOAT, velocity.y, ZERO_FLOAT)
	
	move_and_slide()


func _process(_delta: float) -> void:
	if Global.major_animation_playing:
		if canvas_root:
			canvas_root.visible = false
		
		return
	
	if canvas_root and not canvas_root.visible:
		canvas_root.visible = true
	
	_shoot_control()
	_player_mode_handling()
	_action_bar_updating()
	_overlay_settings_updating()
	
	var ray_collider: Node = aim_ray.get_collider() if aim_ray else null
	
	# based on the player mode will do certain things
	match Global.player_mode:
		Global.PlayerMode.WEAPON:
			pass
		Global.PlayerMode.BUILDING:
			_build_mode_handling(ray_collider)
		# FUTURE DEV: Installation mode disabled
		# Global.PlayerMode.INSTALLING:
		# pass
	
	if (
		Global.player_mode != Global.PlayerMode.BUILDING
		# and Global.player_mode != Global.PlayerMode.INSTALLING # FUTURE DEV: Installation mode disabled
		and not Global.ui_open
	):
		_interaction_handling(ray_collider)


# =============================================================================
# UI & INPUT TIPS
# =============================================================================

func _overlay_settings_updating() -> void:
	if fps_lable and Global.show_fps != fps_lable.visible:
		fps_lable.visible = Global.show_fps
	
	if action_bar == null or action_bar_panel == null:
		return
	
	# hides action bar when UI open
	if Global.ui_open:
		action_bar_panel.visible = false
		return
	
	if action_bar_panel.visible == false:
		action_bar_panel.visible = true
	
	if Global.show_action_bar != action_bar_panel.visible:
		action_bar_panel.visible = Global.show_action_bar


# Updates the action text based on what the player can do
func _action_bar_updating() -> void:
	if action_bar == null:
		return
	
	var action_bar_output: Array[String] = []
	
	if Global.player_mode == Global.PlayerMode.BUILDING:
		action_bar_output.append(BUILDING_INPUTS)
	
	if Global.player_mode != Global.PlayerMode.BUILDING:
		action_bar_output.append(INTERACT_INPUT)
	
	if Global.pined_crafts:
		action_bar_output.append(SHOW_PINNED_INPUT)
	
	if not Global.at_ship:
		if Global.player_mode != Global.PlayerMode.WEAPON:
			action_bar_output.append(WEAPON_MODE_INPUT)
		if Global.player_mode != Global.PlayerMode.BUILDING:
			action_bar_output.append(BUILD_MODE_INPUT)
		# FUTURE DEV: Installation mode disabled
		# if Global.player_mode != Global.PlayerMode.INSTALLING:
		# 	action_bar_output.append(INSTALL_MODE_INPUT)
	
	action_bar.text = "\n".join(action_bar_output)


# Checks if the object the player is looking at is interactable and distance
func _interaction_handling(ray_collider: Node) -> void:
	if interact_overlay == null:
		return
	
	if (
		ray_collider != null
		and ray_collider.is_in_group(GROUP_INTERACTABLE)
		and global_position.distance_to(ray_collider.global_position) < INTERACT_DISTANCE
	):
		interact_overlay.visible = true
		if (
			Input.is_action_just_pressed(ACTION_INTERACT) and
			ray_collider.has_method(METHOD_INTERACT)
		):
			ray_collider.call(METHOD_INTERACT)
	else:
		interact_overlay.visible = false


# Controls if the pined recpes can be seen or not
func _item_pinning_handeling() -> void:
	pass


# =============================================================================
# MODE SWITCHING
# =============================================================================

# Bassed on inputs changes the player mode to shooting, building, installation
func _player_mode_handling() -> void:
	# Weapon mode
	if (
		Input.is_action_just_pressed(ACTION_WEAPON_MODE)
		and Global.player_mode != Global.PlayerMode.WEAPON
	):
		Global.player_mode = Global.PlayerMode.WEAPON
		_disable_building(gun_pivot)
	
	# Build mode
	if (
		Input.is_action_just_pressed(ACTION_BUILD_MODE)
		and not Global.at_ship
		and Global.player_mode != Global.PlayerMode.BUILDING
	):
		Global.player_mode = Global.PlayerMode.BUILDING
		if building_selection:
			building_selection.visible = true
			building_selection.load_selection()
			building_selection.set_process(true)
		if turret_grid and turret_grid.has_method(METHOD_TOGGLE_BUILD_MODE):
			turret_grid.call(METHOD_TOGGLE_BUILD_MODE, true)
		toggle_player_mode_item(hammer_pivot)
	
	# FUTURE DEV: Installation mode disabled for now
	# if (
	# 	Input.is_action_just_pressed(ACTION_INSTALL_MODE)
	# 	and not Global.at_ship
	# 	and Global.player_mode != Global.PlayerMode.INSTALLING
	# ):
	# 	Global.player_mode = Global.PlayerMode.INSTALLING
	# 	_disable_building(wrench_pivot)


# Hides all tool pivots then shows only the one passed in
func toggle_player_mode_item(pivot: Node3D) -> void:
	if gun_pivot:
		gun_pivot.visible = false
	if hammer_pivot:
		hammer_pivot.visible = false
	if wrench_pivot:
		wrench_pivot.visible = false
	
	if pivot:
		pivot.visible = true


# Called when in build or installation mode when in forced extraction to hide ui interfaces
func force_weapon_mode() -> void:
	Global.player_mode = Global.PlayerMode.WEAPON
	_remove_hologram(true)
	_disable_building(gun_pivot)
	
	if building_selection and building_selection.visible:
		building_selection.visible = false


# =============================================================================
# BUILDING - PLACING, PICKINGUP
# =============================================================================

# Handles all building logic
func _build_mode_handling(ray_collider: Node) -> void:
	if Global.player_mode != Global.PlayerMode.BUILDING:
		return
	
	if Input.is_action_just_pressed(ACTION_CHANGE_BUILD_VIEW):
		_toggle_build_view()
		
	if Global.top_down_build_view:
		_update_top_down_build_ray()
	
	# Assign ray_collider dynamically based on current view
	if Global.top_down_build_view and top_down_build_ray:
		ray_collider = top_down_build_ray.get_collider()
	elif build_ray:
		ray_collider = build_ray.get_collider()
	else:
		ray_collider = null
	
	_check_holagram()
	
	var current_selection: String = selected_build
	
	_update_hologram_and_ui(ray_collider, current_selection)
	_handle_placement(ray_collider, current_selection)
	_handle_pickup()


# Checks if there is a holagram
func _check_holagram() -> void:
	if turret_holagram:
		return
	
	if gun_pivot:
		gun_pivot.visible = false
	if interact_overlay:
		interact_overlay.visible = false
		
	if turret_holagram_scene:
		turret_holagram = turret_holagram_scene.instantiate() as Node3D
		add_sibling(turret_holagram)


func _update_hologram_and_ui(ray_collider: Node, current_selection: String) -> void:
	if not turret_holagram:
		return
	
	if current_selection.is_empty() or not DataRegistry.items.has(current_selection):
		turret_holagram.visible = false
		if build_overlay:
			build_overlay.visible = false
		return
	
	var item_type: int = DataRegistry.items[current_selection].type
	turret_holagram.set(BUILD_PROP_CURRENT_ITEM_TYPE, item_type)
	
	if _check_valid_placement(ray_collider, current_selection):
		_snap_hologram_to_grid(ray_collider, current_selection)
		_update_hologram_validity(ray_collider)
		if build_overlay:
			build_overlay.visible = true
	else:
		_move_hologram_to_aim()
		turret_holagram.valid_position = false
		if build_overlay:
			build_overlay.visible = false


func _snap_hologram_to_grid(ray_collider: Node, current_selection: String) -> void:
	var preexisting_build: bool = false
	turret_holagram.visible = true
	
	if not DataRegistry.items.has(current_selection):
		return
		
	var item_type: int = DataRegistry.items[current_selection].type
	
	match item_type:
		Global.ItemType.TURRET:
			if ray_collider.get(BUILD_PROP_ORIGIN_POINT):
				turret_holagram.global_position = ray_collider.turret_origin_point.global_position
			if ray_collider.get(BUILD_PROP_TURRET):
				preexisting_build = true
		Global.ItemType.BASE:
			turret_holagram.global_position = ray_collider.global_position
			if ray_collider.get(BUILD_PROP_BASE):
				preexisting_build = true
	
	if build_label:
		build_label.text = REPLACE_TEXT if preexisting_build else PLACE_TEXT


# Checks if the holagram is in a valid position
func _update_hologram_validity(ray_collider: Node) -> void:
	var dist: float = global_position.distance_to(ray_collider.global_position)
	
	if dist < BUILD_RANGE:
		turret_holagram.valid_position = true
	else:
		turret_holagram.valid_position = false
		if build_label:
			build_label.text = MOVE_CLOSER_TEXT


# Just moves the holagram to where the player is looking
func _move_hologram_to_aim() -> void:
	var active_ray: RayCast3D = top_down_build_ray if Global.top_down_build_view else aim_ray
	
	if active_ray and active_ray.is_colliding():
		turret_holagram.global_position = active_ray.get_collision_point()
		turret_holagram.visible = true
	else:
		turret_holagram.visible = false


# Depending on the type of the build that is selected base or turret
# will call different methods after some safety checks
func _handle_placement(ray_collider: Node, current_selection: String) -> void:
	if current_selection.is_empty() or not Input.is_action_just_pressed(ACTION_PLACE):
		return
	
	if not _check_valid_placement(ray_collider, current_selection):
		return
		
	if global_position.distance_to(ray_collider.global_position) >= BUILD_RANGE:
		return
	
	if not DataRegistry.items.has(current_selection):
		return
		
	var item: ItemData = DataRegistry.items[current_selection]
	if not HelperFunctions.has_item_amount(item):
		return
		
	var can_place: bool = false
	
	match item.type:
		Global.ItemType.TURRET:
			if (
				ray_collider.get(BUILD_PROP_CAN_PLACE_TURRET)
				and ray_collider.has_method(METHOD_PLACE_TURRET)
			):
				can_place = ray_collider.call(METHOD_PLACE_TURRET, current_selection)
		Global.ItemType.BASE:
			if (
				ray_collider.get(BUILD_PROP_CAN_PLACE_BASE)
				and ray_collider.has_method(METHOD_BUILD_BASE)
			):
				can_place = ray_collider.call(METHOD_BUILD_BASE, current_selection)
	
	if can_place:
		if user_interface_animations:
			user_interface_animations.play(PLACE_ANIMATION_KEY)
		if building_selection:
			building_selection.placed_build()


func _handle_pickup() -> void:
	if not Input.is_action_just_pressed(ACTION_PICK_UP_BUILD) or not can_remove_build:
		return
		
	var build_ray_collider: Node = null
	if Global.top_down_build_view and top_down_build_ray:
		build_ray_collider = top_down_build_ray.get_collider()
	elif build_ray:
		build_ray_collider = build_ray.get_collider()
		
	if not build_ray_collider:
		return
		
	if global_position.distance_to(build_ray_collider.global_position) >= BUILD_RANGE:
		return
		
	can_remove_build = false
	
	if build_ray_collider.has_method(METHOD_PICK_UP):
		build_ray_collider.call(METHOD_PICK_UP)
		
	if building_selection:
		building_selection.load_selection()
		
	if build_ray_collider.get(BUILD_PROP_BUILD_TYPE) == Global.BuildTypes.BASE:
		var slot: Variant = build_ray_collider.get(BUILD_PROP_SLOT)
		if slot is Node and (slot as Node).has_method(METHOD_BASE_REMOVED):
			(slot as Node).call(METHOD_BASE_REMOVED)
			
	var tree := get_tree()
	if tree:
		await tree.create_timer(REMOVE_BUILD_DELAY).timeout
	
	can_remove_build = true


# Returns true if the current ray collider is a valid unlocked turret slot
func _check_valid_placement(ray_collider: Node, current_selection: String) -> bool:
	if (
		ray_collider == null
		or not ray_collider.is_in_group(GROUP_TURRET_SLOTS)
		or not ray_collider.get(BUILD_PROP_UNLOCKED)
	):
		return false
	
	if current_selection.is_empty() or not DataRegistry.items.has(current_selection):
		return false
		
	var item_type: int = DataRegistry.items[current_selection].type
	
	match item_type:
		Global.ItemType.TURRET:
			return ray_collider.get(BUILD_PROP_BASE) != null
		Global.ItemType.BASE:
			return true
	
	return false


# removes the current hologram
func _remove_hologram(change_mode: bool = false) -> void:
	if gun_pivot:
		gun_pivot.visible = true
	if turret_holagram:
		turret_holagram.queue_free()
	if build_overlay:
		build_overlay.visible = false
	if change_mode and not Global.at_ship and turret_grid:
		if turret_grid.has_method(METHOD_TOGGLE_BUILD_MODE):
			turret_grid.call(METHOD_TOGGLE_BUILD_MODE, false)


# updats the postion of the build ray to where the mouse is 
func _update_top_down_build_ray() -> void:
	if not Global.top_down_build_view:
		return
	
	if not build_camera or not top_down_build_ray:
		return
	
	var mouse_position := get_viewport().get_mouse_position()
	
	var ray_origin := build_camera.global_position
	var ray_direction := build_camera.project_ray_normal(mouse_position)
	
	var ray_end := ray_origin + (ray_direction * BUILD_RAY_LENGTH)
	
	if reticle_root:
		reticle_root.position = mouse_position
	if build_overlay:
		build_overlay.position = mouse_position
	
	top_down_build_ray.global_position = ray_origin
	
	# Fix: In Godot 4, target_position is local. to_local gives us the correct local vector length and direction.
	top_down_build_ray.target_position = top_down_build_ray.to_local(ray_end)
	
	top_down_build_ray.force_raycast_update()


func _toggle_build_view() -> void:
	Global.top_down_build_view = not Global.top_down_build_view
		
	if Global.top_down_build_view:
		top_down_shader.visible = true
		build_camera.current = true
		normal_camera.current = false
		
	else:
		top_down_shader.visible = false
		if reticle_root:
			reticle_root.position = get_viewport().get_visible_rect().size / 2
		build_camera.current = false
		normal_camera.current = true
		
	HelperFunctions.set_mouse_captured(true, not Global.top_down_build_view)


func _disable_building(piviot_item : Node3D) -> void:
	_remove_hologram(true)
	toggle_player_mode_item(piviot_item)
	
	if Global.top_down_build_view:
		_toggle_build_view()


# =============================================================================
# COMBAT & SHOOTING
# =============================================================================


# Checks if the player is allowed to shoot and starts the cooldown timer.
func _shoot_control() -> void:
	if (
		Global.player_mode != Global.PlayerMode.WEAPON
		or weapon == null
		or Global.ui_open
	):
		return
	
	if Input.is_action_pressed(ACTION_SHOOT) and can_shoot:
		can_shoot = false
		if shooting_timer:
			shooting_timer.start()
		else:
			can_shoot = true
		_shoot()


# gets the gun to shoot basson on its properties
func _shoot() -> void:
	var to: Vector3
	if aim_ray and aim_ray.is_colliding():
		to = aim_ray.get_collision_point()
		var hit: Node = aim_ray.get_collider()
		
		if hit and hit.has_meta(ENEMY_METADATA_TAG) and hit.has_method(METHOD_HIT):
			if weapon_resource and weapon_resource.get_critical():
				hit.call(
					METHOD_HIT,
					weapon_resource.damage * weapon_resource.critical_multiplier,
					true
				)
			elif weapon_resource:
				hit.call(METHOD_HIT, weapon_resource.damage)
			
			if hit_overlay:
				hit_overlay.visible = true
				await get_tree().create_timer(HIT_OVERLAY_TIME).timeout
				if hit_overlay:
					hit_overlay.visible = false
			
			if weapon_resource:
				HelperFunctions.spawn_temp_sound(weapon_resource.hit_resource)
	else:
		var forward_vector: Vector3 = -aim_ray.global_basis.z if aim_ray else Vector3.FORWARD
		var max_distance: float = aim_ray.target_position.length() if aim_ray else 100.0
		var origin: Vector3 = aim_ray.global_position if aim_ray else global_position
		to = origin + (forward_vector * max_distance)
	
	var from: Vector3 = (
		weapon.get(PROP_BULLET_SPAWN).global_position
		if weapon and weapon.get(PROP_BULLET_SPAWN)
		else global_position)
	
	if DataRegistry.bullet_trail.has(weapon_name):
		HelperFunctions.create_bullet_trail(from, to, DataRegistry.bullet_trail[weapon_name])
	if weapon_resource:
		HelperFunctions.spawn_temp_sound(weapon_resource.shoot_resource, from)


# sets the weapon of the player to the current weapon resource
func _set_new_weapon() -> void:
	weapon = null
	weapon_resource = null
	
	if gun_pivot and gun_pivot.get_child_count() > GUN_CHILD_INDEX:
		weapon = gun_pivot.get_child(GUN_CHILD_INDEX)
		if DataRegistry.weapon.has(weapon_name):
			weapon_resource = DataRegistry.weapon[weapon_name]
			if shooting_timer and weapon_resource:
				shooting_timer.wait_time = weapon_resource.cool_down


func _on_shoot_timer_timeout() -> void:
	can_shoot = true


# PICKUP ======================================================================
# Called when a drop enters the pickup area making it start moving
func _on_pick_up_area_body_entered(body: Node3D) -> void:
	if body and body.is_in_group(GROUP_DROPS) and body.get(PROP_VALID):
		body.set(PROP_PLAYER, self)
		if body.has_method(METHOD_PRIME_PICK_UP):
			body.prime_pick_up()
