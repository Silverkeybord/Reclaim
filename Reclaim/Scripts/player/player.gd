class_name Player
extends CharacterBody3D

# =============================================================================
# CONSTANTS
# =============================================================================

# Use string names instead of normal strings as it save on compute for actions and inputs

# Input Action Names
const ACTION_LEFT : StringName = &"left"
const ACTION_RIGHT : StringName = &"right"
const ACTION_FORWARD : StringName = &"forward"
const ACTION_BACK : StringName = &"back"
const ACTION_JUMP : StringName = &"jump"
const ACTION_SHOOT : StringName = &"shoot"
const ACTION_INTERACT : StringName = &"interact"
const ACTION_WEAPON_MODE : StringName = &"weapon_mode"
const ACTION_BUILD_MODE : StringName = &"build_mode"
const ACTION_INSTALL_MODE : StringName = &"install_mode"
const ACTION_CHANGE_BUILD_MODE : StringName = &"change_build_mode"
const ACTION_PLACE : StringName = &"place"
const ACTION_PICK_UP_BUILD : StringName = &"pick_up_build"

# Groups & Metadata Tags
const GROUP_INTERACTABLE : StringName = &"interactable"
const GROUP_DROPS : StringName = &"drops"
const GROUP_TURRET_SLOTS : StringName = &"turret_slots"
const ENEMY_METADATA_TAG : StringName = &"enemy"

# Dynamic Property & Method String Names
const PROP_VALID : StringName = &"valid"
const PROP_PLAYER : StringName = &"player"
const PROP_BULLET_SPAWN : StringName = &"bullet_spawn"

const METHOD_INTERACT : StringName = &"interact"
const METHOD_TOGGLE_BUILD_MODE : StringName = &"_toggle_build_mode"
const METHOD_PRIME_PICK_UP : StringName = &"prime_pick_up"

# Animation Keys & Defaults
const PLACE_ANIMATION_KEY : StringName = &"build_placed"
const DEFAULT_WEAPON_NAME : String = "pistol"

# UI Display Strings
const WEAPON_MODE_INPUT : String = "1 - Weapon"
const BUILD_MODE_INPUT : String = "2 - Building"
const INSTALL_MODE_INPUT : String = "3 - Installation"
const BUILDING_INPUTS : String = "F - Change Builds\nM2 - Pick up Builds\nScroll - Selection"
const INTERACT_INPUT : String = "E - Interact"

const PICK_UP_TEXT : String = "CLICK TO PICK UP"
const PLACE_TEXT : String = "CLICK TO PLACE"
const REPLACE_TEXT : String = "CLICK TO REPLACE"
const MOVE_CLOSER_TEXT : String = "MOVE CLOSER"

# Physics & Interaction Parameters
const GRAVITY : float = 40.0
const INTERACT_DISTANCE : float = 5.0
const BUILD_RANGE : float = 25.0
const GUN_CHILD_INDEX : int = 0
const REMOVE_BUILD_DELAY : float = 0.1
const HIT_OVERLAY_TIME : float = 0.08
const PICK_UP_COOLDOWN : float = 2.0
const ZERO_FLOAT : float = 0.0

# =============================================================================
# EXPORTS
# =============================================================================

@export_group("Player Stats")
@export var jump_velocity: float = 40.0 # was 20 debugging
@export var move_speed: float = 30.0 # was 14 debugging
@export var in_shield: bool = false

@export_group("In Scene References")
@export var interact_overlay: Control
@export var hit_overlay: Control
@export var aim_ray: RayCast3D
@export var build_ray: RayCast3D
@export var shooting_timer: Timer
@export var pick_up_area: Area3D

@export_subgroup("Pivots")
@export var arm_pivot: Node3D
@export var gun_pivot: Node3D
@export var hammer_pivot: Node3D
@export var wrench_pivot: Node3D

@export_group("Turrets & Building")
@export var turret_holagram_scene: PackedScene
@export var turret_grid: Node3D
@export var selected_turret: String = ""
@export var selected_base: String = ""

@export_group("2D UI Elements")
@export var canvas_root : CanvasLayer
@export var build_overlay: Control
@export var build_label: Label
@export var input_tip: Label
@export var building_selection: CanvasLayer
@export var user_interface_animations: AnimationPlayer
@export var item_notif_controller : Control

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
	_set_new_weapon()


func _physics_process(delta: float) -> void:
	if Global.major_animation_playing:
		return
	
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = ZERO_FLOAT
	
	if not Global.crafting_open and not Global.extraction_open:
		var input_dir := Input.get_vector(ACTION_LEFT, ACTION_RIGHT, ACTION_FORWARD, ACTION_BACK)
		var direction := (global_basis * Vector3(input_dir.x,ZERO_FLOAT, input_dir.y)).normalized()
		
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		
		if Input.is_action_pressed(ACTION_JUMP) and is_on_floor():
			velocity.y = jump_velocity
	else:
		velocity = Vector3(ZERO_FLOAT, velocity.y,ZERO_FLOAT)
	
	move_and_slide()


func _process(_delta: float) -> void:
	if Global.major_animation_playing:
		canvas_root.visible = false
		return
	
	if not canvas_root.visible:
		canvas_root.visible = true
	
	_shoot_control()
	_player_mode_handling()
	_input_tip_updating()
	
	var ray_collider: Node = aim_ray.get_collider() if aim_ray else null
	
	match Global.player_mode:
		Global.PLAYER_MODES.WEAPON:
			pass
		Global.PLAYER_MODES.BUILDING:
			_build_mode_handling(ray_collider)
		Global.PLAYER_MODES.INSTALLING:
			pass
	
	if (
		Global.player_mode != Global.PLAYER_MODES.BUILDING
		and Global.player_mode != Global.PLAYER_MODES.INSTALLING
		and not Global.ui_open
	):
		_interaction_handling(ray_collider)

# =============================================================================
# UI & INPUT TIPS
# =============================================================================

func _input_tip_updating() -> void:
	if input_tip == null:
		return

	var input_tip_output: Array[String] = []
	
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
	
	input_tip.text = "\n".join(input_tip_output)


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
			ray_collider.interact()
	else:
		interact_overlay.visible = false

# =============================================================================
# MODE SWITCHING
# =============================================================================

func _player_mode_handling() -> void:
	if (
		Input.is_action_just_pressed(ACTION_WEAPON_MODE)
		and Global.player_mode != Global.PLAYER_MODES.WEAPON
	):
		Global.player_mode = Global.PLAYER_MODES.WEAPON
		_remove_hologram(true)
		toggle_player_mode_item(gun_pivot)
	
	if (
		Input.is_action_just_pressed(ACTION_BUILD_MODE)
		and not Global.at_ship
		and Global.player_mode != Global.PLAYER_MODES.BUILDING
	):
		Global.player_mode = Global.PLAYER_MODES.BUILDING
		if building_selection:
			building_selection.visible = true
			building_selection.load_selection()
			building_selection.set_process(true)
		if turret_grid and turret_grid.has_method(METHOD_TOGGLE_BUILD_MODE):
			turret_grid._toggle_build_mode(true)
		toggle_player_mode_item(hammer_pivot)
	
	if (
		Input.is_action_just_pressed(ACTION_INSTALL_MODE)
		and not Global.at_ship
		and Global.player_mode != Global.PLAYER_MODES.INSTALLING
	):
		Global.player_mode = Global.PLAYER_MODES.INSTALLING
		_remove_hologram(true)
		toggle_player_mode_item(wrench_pivot)


func toggle_player_mode_item(pivot: Node3D) -> void:
	if gun_pivot:
		gun_pivot.visible = false
	if hammer_pivot:
		hammer_pivot.visible = false
	if wrench_pivot:
		wrench_pivot.visible = false
	
	if pivot:
		pivot.visible = true

# =============================================================================
# BUILDING & HOLOGRAMS
# =============================================================================

func _build_mode_handling(ray_collider: Node) -> void:
	var build_ray_collider: Node = build_ray.get_collider() if build_ray else null
	var current_build_selected: String = ""
	
	if Global.player_mode == Global.PLAYER_MODES.BUILDING and not turret_holagram:
		if gun_pivot:
			gun_pivot.visible = false
		if turret_holagram_scene:
			turret_holagram = turret_holagram_scene.instantiate()
			add_sibling(turret_holagram)
		if interact_overlay:
			interact_overlay.visible = false
	
	if Input.is_action_just_pressed(ACTION_CHANGE_BUILD_MODE):
		var build_modes: int = Global.BUILD_MODES.size()
		Global.current_build_mode = (
			((Global.current_build_mode + 1) % build_modes) as Global.BUILD_MODES
		)
		if building_selection:
			building_selection.change_build_mode()
	
	match Global.current_build_mode:
		Global.BUILD_MODES.TURRET:
			if not selected_turret.is_empty():
				current_build_selected = selected_turret
		Global.BUILD_MODES.BASE:
			if not selected_base.is_empty():
				current_build_selected = selected_base
	
	if turret_holagram:
		if _check_valid_placement(ray_collider) and not current_build_selected.is_empty():
			var preexisting_build: bool = false
			
			match Global.current_build_mode:
				Global.BUILD_MODES.TURRET:
					turret_holagram.visible = true
					turret_holagram.global_position = (
						ray_collider.turret_origin_point.global_position)
					if ray_collider.turret:
						preexisting_build = true
				
				Global.BUILD_MODES.BASE:
					turret_holagram.visible = true
					turret_holagram.global_position = ray_collider.global_position
					if ray_collider.base:
						preexisting_build = true
			
			if global_position.distance_to(ray_collider.global_position) < BUILD_RANGE:
				turret_holagram.valid_position = true
				build_label.text = REPLACE_TEXT if preexisting_build else PLACE_TEXT
			else:
				build_label.text = MOVE_CLOSER_TEXT
				turret_holagram.valid_position = false
			
			if build_overlay:
				build_overlay.visible = true
		
		elif not current_build_selected.is_empty():
			if aim_ray and aim_ray.is_colliding():
				turret_holagram.global_position = aim_ray.get_collision_point()
				turret_holagram.visible = true
			else:
				turret_holagram.visible = false
				
			turret_holagram.valid_position = false
			if build_overlay:
				build_overlay.visible = false
		else:
			turret_holagram.visible = false
			if build_overlay:
				build_overlay.visible = false
	
	if Input.is_action_just_pressed(ACTION_PLACE) and not current_build_selected.is_empty():
		if (
			_check_valid_placement(ray_collider)
			and global_position.distance_to(ray_collider.global_position) < BUILD_RANGE
		):
			var can_place: bool = false
			
			if user_interface_animations:
				user_interface_animations.play(PLACE_ANIMATION_KEY)
			
			match Global.current_build_mode:
				Global.BUILD_MODES.TURRET:
					if ray_collider.can_place_turret:
						if HelperFunctions.has_item_amount(DataRegistry.items[selected_turret]):
							can_place = ray_collider.place_selected_turret(selected_turret)
				
				Global.BUILD_MODES.BASE:
					if ray_collider.can_place_base:
						if HelperFunctions.has_item_amount(DataRegistry.items[selected_base]):
							can_place = ray_collider.build_base(selected_base)
			
			if can_place and building_selection:
				building_selection.placed_build()
	
	if Input.is_action_just_pressed(ACTION_PICK_UP_BUILD):
		if (
			can_remove_build
			and build_ray_collider
			and global_position.distance_to(build_ray_collider.global_position) < BUILD_RANGE
		):
			can_remove_build = false
			build_ray_collider.pick_up()
			
			if building_selection:
				building_selection.load_selection()
			
			if build_ray_collider.build_type == Global.BUILD_TYPES.BASE:
				build_ray_collider.slot.base_removed()
			
			await get_tree().create_timer(REMOVE_BUILD_DELAY).timeout
			can_remove_build = true


func _check_valid_placement(ray_collider: Node) -> bool:
	if (
		ray_collider == null
		or not ray_collider.is_in_group(GROUP_TURRET_SLOTS)
		or not ray_collider.unlocked
	):
		return false
	
	match Global.current_build_mode:
		Global.BUILD_MODES.TURRET:
			return ray_collider.base != null
		Global.BUILD_MODES.BASE:
			return true
	
	return false


func _remove_hologram(change_mode: bool = false) -> void:
	if gun_pivot:
		gun_pivot.visible = true
	if turret_holagram:
		turret_holagram.queue_free()
	if build_overlay:
		build_overlay.visible = false
	
	if change_mode and not Global.at_ship and turret_grid:
		if turret_grid.has_method(METHOD_TOGGLE_BUILD_MODE):
			turret_grid._toggle_build_mode(false)

# =============================================================================
# COMBAT & SHOOTING
# =============================================================================

func _shoot_control() -> void:
	if (
		Global.player_mode != Global.PLAYER_MODES.WEAPON
		or weapon == null
		or Global.crafting_open
		or Global.extraction_open
	):
		return
	
	if Input.is_action_pressed(ACTION_SHOOT) and can_shoot:
		can_shoot = false
		if shooting_timer:
			shooting_timer.start()
		_shoot()


func _shoot() -> void:
	var to: Vector3
	
	if aim_ray and aim_ray.is_colliding():
		to = aim_ray.get_collision_point()
		var hit: Node = aim_ray.get_collider()
		
		if hit and hit.has_meta(ENEMY_METADATA_TAG):
			if weapon_resource and weapon_resource.get_critical():
				hit.hit(weapon_resource.damage * weapon_resource.critical_multiplier, true)
			elif weapon_resource:
				hit.hit(weapon_resource.damage)
			
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


func _set_new_weapon() -> void:
	if gun_pivot and gun_pivot.get_child_count() > GUN_CHILD_INDEX:
		weapon = gun_pivot.get_child(GUN_CHILD_INDEX)
	
	if DataRegistry.weapon.has(weapon_name):
		weapon_resource = DataRegistry.weapon[weapon_name]
		if shooting_timer and weapon_resource:
			shooting_timer.wait_time = weapon_resource.cool_down


func _on_shoot_timer_timeout() -> void:
	can_shoot = true

# =============================================================================
# PICKUP SYSTEM
# =============================================================================

func _on_pick_up_area_body_entered(body: Node3D) -> void:
	if body and body.is_in_group(GROUP_DROPS) and body.get(PROP_VALID):
		body.set(PROP_PLAYER, self)
		if body.has_method(METHOD_PRIME_PICK_UP):
			body.prime_pick_up()
