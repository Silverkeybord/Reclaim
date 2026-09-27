class_name EnemySpawner
extends Node3D

const BASIC_ENEMY_FALLBACK : PackedScene = preload("res://scenes/enemies/enemy_scenes/basic.tscn")
const ENEMY_SIZE_FALLBACK : float = 1

const ERR_NO_CLEAR_SPAWNING := "No Clear Spawning : %s"

const SPAWN_MARKERS_GROUP : String = "enemy_spawn_markers"

const ENEMIES_SCENE_FOLDER := "res://scenes/enemies/enemy_scenes/"
const SLASH_FORMATTING := "/"

const INVALID_SCENE_FOLDER := "Invalid Scene Folder"
const INVALID_ENEMY_SCENE := "Invalid Enemy Scene"
const INVALID_ENEMY_WEIGHTS := "Invalid Enemy Weights"

const GROUP_ENEMYS := "enemys"

const DEFAULT_SPAWN_RADIUS := 5.0

const SPAWN_RADIUS_PROPERTY : StringName = &"spawn_radius"

enum WaveState { SPAWNING, CLEARING, BREATHING, SECTOR_CLEARED }

@export_group("In Scene")
@export var spawn_timer : Timer

@export_group("Map Info")
@export var sector_elements : SectorElements
## The map this is placed on
@export var map : String
@export var wave_data : WaveData

@export var spawn_nodes : Array[Marker3D]

var spawn_rate_ratio : float # The spawn rate drop-off in terms of time alive
var spawn_rate : float

var cluster_rate_ratio : float # The cluster decay in terms of time alive
var cluster_size : int
var commander_size_ratio : float
var normal_size_ratio : float

var enemy_scene : PackedScene

var run_time := 0.0
var current_spawn_section : SpawnSection
var current_spawn_index : int = 0

# Wave management variables
var wave_state: int = WaveState.BREATHING
var phase_timer: float = 0.0

@onready var enemy_scenes := get_enemy_scenes()


func _ready() -> void:
	set_process(false)


# called from sector elements after animation is finished or skipped
func start_sector() -> void:
	current_spawn_index = 0
	if wave_data.spawning.size() > 0:
		current_spawn_section = wave_data.spawning[current_spawn_index]
		_start_breathing_phase()
		set_process(true)


func _start_breathing_phase() -> void:
	wave_state = WaveState.BREATHING
	phase_timer = current_spawn_section.breathing_room
	spawn_timer.stop()


func _start_spawning_phase() -> void:
	wave_state = WaveState.SPAWNING
	phase_timer = current_spawn_section.duration
	spawn_timer.start(current_spawn_section.spawn_interval)
	_on_spawn_timer_timeout() # Optional: Trigger first spawn immediately on phase start


func _start_clearing_phase() -> void:
	wave_state = WaveState.CLEARING
	spawn_timer.stop()


func _start_sector_cleared_phase() -> void:
	wave_state = WaveState.SECTOR_CLEARED
	if wave_data.clear_spawning:
		current_spawn_section = wave_data.clear_spawning
		spawn_timer.start(current_spawn_section.spawn_interval)
	else:
		push_error(ERR_NO_CLEAR_SPAWNING % wave_data.key)
		set_process(false)


func _process(delta: float) -> void:
	if Global.major_animation_playing:
		return
	
	run_time += delta
	
	# Update the UI via Sector Shield Run UI reference
	if sector_elements and sector_elements.sector_shield and sector_elements.sector_shield.run_ui:
		var run_ui = sector_elements.sector_shield.run_ui
		run_ui.current_wave = current_spawn_index + 1
		run_ui.current_state = wave_state
		run_ui.phase_time_left = phase_timer
		
		if wave_state == WaveState.CLEARING:
			run_ui.enemies_left = get_tree().get_node_count_in_group(GROUP_ENEMYS)
	
	# Handle Wave State Machine
	match wave_state:
		WaveState.BREATHING:
			phase_timer -= delta
			if phase_timer <= 0:
				_start_spawning_phase()
				
		WaveState.SPAWNING:
			phase_timer -= delta
			if phase_timer <= 0:
				_start_clearing_phase()
				
		WaveState.CLEARING:
			var enemies_alive = get_tree().get_node_count_in_group(GROUP_ENEMYS)
			if enemies_alive == 0:
				current_spawn_index += 1
				if current_spawn_index < wave_data.spawning.size():
					current_spawn_section = wave_data.spawning[current_spawn_index]
					_start_breathing_phase()
				else:
					_start_sector_cleared_phase() # All waves finished, start trickling
					
		WaveState.SECTOR_CLEARED:
			pass 


# Enemy spawning =============================================================
func _on_spawn_timer_timeout() -> void:
	# calculate dynamic values based on active run time
	var time_ratio : float = get_time_ratio()
	
	if Global.enemies >= Global.MAX_SPHERES:
		return
	
	# If swarm in activated enemies will spawn from all spawn nodes if not just one
	var selected_spawn_nodes : Array[Marker3D]
	
	if current_spawn_section.swarm:
		selected_spawn_nodes = spawn_nodes
	else:
		selected_spawn_nodes.append(spawn_nodes.pick_random())
	
	var commander : BaseEnemy
	
	for spawn_node in selected_spawn_nodes:
		# Spawning Commander if condition met
		if current_spawn_section.commanders:
			commander = spawn_enemy(spawn_node, true)
		
		var spawn_amount = current_spawn_section.spawn_amount
		
		if current_spawn_section.random_additional_enemies:
			spawn_amount += randi_range(0, current_spawn_section.random_additional_enemies)
		
		if current_spawn_section.end_additional_enemy_amount:
			spawn_amount += floori(time_ratio * current_spawn_section.end_additional_enemy_amount)
		
		var center_enemy_spawn: Node3D = spawn_node
		if commander:
			center_enemy_spawn = commander
		
		# normal enemies spawning
		for x in range(spawn_amount):
			spawn_enemy(center_enemy_spawn)
	
	# Starting next spawn interval
	if current_spawn_section.end_spawn_rate:
		var interval_difference = current_spawn_section.end_spawn_rate - current_spawn_section.spawn_interval
		var scaleing_spawn_interval = interval_difference * time_ratio
		
		spawn_timer.start(current_spawn_section.spawn_interval + scaleing_spawn_interval)
	else:
		spawn_timer.start(current_spawn_section.spawn_interval)


func spawn_enemy(spawn_node : Node3D, is_commander := false) -> BaseEnemy:
	var enemy := _get_enemy_type_scene().instantiate() as BaseEnemy
	add_sibling(enemy)
	enemy.add_to_group(GROUP_ENEMYS)
	
	# setting properties
	enemy.extraction_pod = sector_elements.extraction_pod
	enemy.sector_shield = sector_elements.sector_shield
	enemy.size = _get_enemy_size()
	
	var spawn_radius = DEFAULT_SPAWN_RADIUS
	
	if SPAWN_RADIUS_PROPERTY in spawn_node:
		spawn_radius = spawn_node.spawn_radius
	
	enemy.global_position = _spawn_in_radius(
		spawn_node.global_position,
		spawn_radius, 
		enemy.size
	)
	
	# sets commander status
	if is_commander:
		enemy.is_commander = is_commander
		enemy.size += EnemyData.COMMANDER_ADDITIONAL_SIZE
	
	enemy.scale *= enemy.size
	
	enemy.finish_loading()
	
	return enemy


# returns the scene of the enemy bassed on the current spawn section weights
func _get_enemy_type_scene() -> PackedScene:
	if current_spawn_section.enemies.is_empty():
		return BASIC_ENEMY_FALLBACK
	
	var total_weight: float = 0.0
	for enemy_weight : EnemyWeight in current_spawn_section.enemies:
		if enemy_weight:
			total_weight += enemy_weight.weight
	
	if total_weight <= 0.0:
		return BASIC_ENEMY_FALLBACK
	
	var roll: float = randf() * total_weight
	for enemy_weight : EnemyWeight in current_spawn_section.enemies:
		if enemy_weight == null:
			continue
		
		roll -= enemy_weight.weight
		if roll <= 0.0:
			if enemy_weight.enemy_name == null:
				return BASIC_ENEMY_FALLBACK
			
			return enemy_scenes[enemy_weight.enemy_name]
	
	return BASIC_ENEMY_FALLBACK


# returns a float for the size of the enemy to be multplyed by vector.one
func _get_enemy_size() -> float:
	var spawn_sizes = current_spawn_section.spawn_sizes
	
	var total_weight: float = 0.0
	for size : String in spawn_sizes:
		total_weight += spawn_sizes[size]
	
	if total_weight <= 0.0:
		return ENEMY_SIZE_FALLBACK
	
	var roll: float = randf() * total_weight
	for size : String in spawn_sizes:
		if size == null:
			continue
		
		roll -= spawn_sizes[size]
		if roll <= 0.0:
			if spawn_sizes[size] == 0:
				continue
			
			return EnemyData.SPAWN_SIZES[size]
	
	return ENEMY_SIZE_FALLBACK


func get_time_ratio() -> float:
	# Keep the time ratio flat at 0 during the cleared trickle so spawn rate scaling doesn't break
	if wave_state == WaveState.SECTOR_CLEARED:
		return 0.0
		
	if current_spawn_section.duration <= 0:
		return 1.0
	return 1.0 - clampf(phase_timer / current_spawn_section.duration, 0.0, 1.0)


# Helper function to calculate a random XZ position within a given radius
func _spawn_in_radius(
	center_position: Vector3, 
	max_radius: float, 
	size : float,
	min_radius : float = 0.0
	) -> Vector3:
	
	var radius = randf_range(min_radius, max_radius)
	var angle = randf_range(0, TAU)
	var x_offset = sin(angle) * radius
	var z_offset = cos(angle) * radius
	
	return center_position + Vector3(x_offset, (size / 2), z_offset)


# Gets gets all the enemies from the file
func get_enemy_scenes() -> Dictionary:
	var enemy_scene_folder = DirAccess.open(ENEMIES_SCENE_FOLDER)
	var returning_dict : Dictionary = {}
	
	if not enemy_scene_folder:
		push_error(INVALID_SCENE_FOLDER)
		return {}
	
	var enemy_scene_files = enemy_scene_folder.get_files()
	
	# Same problem as the resource files loading exported versions add a remap extention
	for file_name in enemy_scene_files:
		var clean_file_name: String = file_name
		
		if clean_file_name.ends_with(DataRegistry.REMAP_FILE_EXTENSION):
			clean_file_name = clean_file_name.trim_suffix(DataRegistry.REMAP_FILE_EXTENSION)
		
		if not clean_file_name.ends_with(DataRegistry.SCENE_FILE_EXTENTION):
			continue
		
		var path := (
			enemy_scene_folder.get_current_dir() +
			SLASH_FORMATTING +
			clean_file_name
		)
		
		if not ResourceLoader.exists(path):
			continue
		
		var scene: PackedScene = load(path)
		
		var key_name := clean_file_name.get_basename()
		returning_dict[key_name] = scene
	
	return returning_dict
