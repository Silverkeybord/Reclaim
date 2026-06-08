extends Node3D

const BASIC_TYPE_FALLBACK : String = "basic"
const SPAWN_MARKERS_GROUP : String = "enemy_spawn_markers"

@export_group("Enemies")
@export var enemy_scene : PackedScene

@export_group("In Scene")
@export var spawn_timer : Timer

@export_group("Map Info")
## The target for spawned enemies
@export var extraction_pod : Node3D
## The map this is placed on
@export var map : String

var wave_data : WaveData # Calls class to get autocomplete
var difficulty_mult : int

var spawn_rate_ratio : float # The spawn rate drop-off in terms of time alive
var spawn_rate : float
var spawn_nodes : Array[Node]

var cluster_rate_ratio : float # The cluster decay in terms of time alive
var cluster_size : int
var commander_size_raito : float
var normal_size_ratio : float

var wave_enemies : Dictionary
var run_time := 0.0


func _ready() -> void:
	# Sets the resource
	wave_data = GameData.wave[map]
	
	# Gets the enemies that will spawn in this sector and probiblities
	for x in wave_data.enemies:
		if wave_data.enemies[x] > 0:
			wave_enemies[x] = wave_data.enemies[x]
	
	# Calculates ratios
	spawn_rate = wave_data.spawn_start_rate
	normal_size_ratio = _get_time_raito(wave_data.start_size, wave_data.end_size)
	spawn_rate_ratio = _get_time_raito(wave_data.spawn_start_rate, wave_data.spawn_end_rate)
	cluster_rate_ratio = _get_time_raito(wave_data.cluster_start_size, wave_data.cluster_end_size)
	commander_size_raito = _get_time_raito(
		wave_data.commander_start_size, wave_data.commander_end_size)
	
	spawn_nodes = get_tree().get_nodes_in_group(SPAWN_MARKERS_GROUP)
	spawn_timer.start(spawn_rate)


func _process(delta: float) -> void:
	run_time += delta
	Global.sector_run_time = run_time


func _on_spawn_timer_timeout() -> void:
	# Calculate dynamic values based on active run time
	cluster_size = wave_data.cluster_start_size - round(run_time * cluster_rate_ratio)
	spawn_rate = wave_data.spawn_start_rate - (run_time * spawn_rate_ratio)
	spawn_timer.start(spawn_rate)
	
	if Global.enemies >= Global.MAX_SPHERES:
		return
	
	var random_spawn_node = spawn_nodes.pick_random()
	var commander : base_enemy = enemy_scene.instantiate()
	add_sibling(commander)
	
	# sets the resourse of the commander
	commander.enemy_resourse = _get_enemy_type_resourse()
	
	# Commander Positioning
	commander.global_position = _spawn_in_radus(
		random_spawn_node.global_position, wave_data.cluster_spawn_radius
	)
	
	commander.extraction_pod = extraction_pod
	commander.size = (
		wave_data.commander_start_size + 
		Global.sector_run_time * commander_size_raito + 
		randf_range(0, wave_data.commander_random_additional_size)
		)
	commander.scale *= commander.size
	commander.is_commander = true
	commander.fin_loading()
	
	# Squad Cluster Spawning Loop
	for x in range(cluster_size):
		var new_enemy : base_enemy = enemy_scene.instantiate()
		add_sibling(new_enemy)
		
		new_enemy.enemy_resourse = _get_enemy_type_resourse()
		
		new_enemy.global_position = _spawn_in_radus(
			commander.global_position, 
			wave_data.enemy_spawn_radius,
			commander.size
		)
		
		new_enemy.extraction_pod = extraction_pod
		new_enemy.size = (
			wave_data.start_size +
			Global.sector_run_time * normal_size_ratio +
			randf_range(-wave_data.random_aditional_size, wave_data.random_aditional_size)
			)
		new_enemy.scale *= new_enemy.size
		new_enemy.fin_loading()


# Helper function to calculate a random XZ position within a given radius
func _spawn_in_radus(
	center_position: Vector3, 
	max_radius: float, 
	min_radius : float = 0.0
	) -> Vector3:
	
	var radius = randf_range(min_radius, max_radius)
	var angle = randf_range(0, TAU)
	var x_offset = sin(angle) * radius
	var z_offset = cos(angle) * radius
	
	return center_position + Vector3(x_offset, 0, z_offset)


func _get_enemy_type_resourse():
	
	var value = randf()
	var enemy_weight : float = 0.0
	
	for x in wave_enemies:
		enemy_weight += wave_enemies[x] / Global.PROBABLITY_DIVIDE_CONSTANT
		if enemy_weight > value:
			return GameData.enemies[x]
	
	print("invalid weights returning basic on map : ", map)
	return GameData.enemies[BASIC_TYPE_FALLBACK]


func _get_time_raito(start_value: float, end_value: float) -> float:
	return (end_value - start_value) / wave_data.end_time
	
