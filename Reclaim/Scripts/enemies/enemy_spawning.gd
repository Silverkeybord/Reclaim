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

@export var sector_shield : SectorShield

var wave_resource : WaveData
var difficulty_mult : int

var spawn_rate_ratio : float # The spawn rate drop-off in terms of time alive
var spawn_rate : float
var spawn_nodes : Array[Node]

var cluster_rate_ratio : float # The cluster decay in terms of time alive
var cluster_size : int
var commander_size_ratio : float
var normal_size_ratio : float

var run_time := 0.0


func _ready() -> void:
	# Sets the resource
	wave_resource = DataRegistry.wave[map]
	
	
	# Calculates ratios
	spawn_rate = wave_resource.spawn_start_interval
	normal_size_ratio = _get_time_ratio(wave_resource.start_size, wave_resource.end_size)
	spawn_rate_ratio = _get_time_ratio(
		wave_resource.spawn_start_interval, wave_resource.spawn_end_interval
		)
	cluster_rate_ratio = _get_time_ratio(
		wave_resource.cluster_start_size, wave_resource.cluster_end_size
		)
	commander_size_ratio = _get_time_ratio(
		wave_resource.commander_start_size, wave_resource.commander_end_size
		)
	
	spawn_nodes = get_tree().get_nodes_in_group(SPAWN_MARKERS_GROUP)
	spawn_timer.start(spawn_rate)


func _process(delta: float) -> void:
	run_time += delta
	Global.sector_run_time = run_time


# spawns the cluster after each time
func _on_spawn_timer_timeout() -> void:
	# calculate dynamic values based on active run time
	cluster_size = wave_resource.cluster_start_size - round(run_time * cluster_rate_ratio)
	spawn_rate = wave_resource.spawn_start_interval - (run_time * spawn_rate_ratio)
	spawn_timer.start(spawn_rate)
	
	if Global.enemies >= Global.MAX_SPHERES:
		return
	
	var random_spawn_node = spawn_nodes.pick_random()
	var commander : BaseEnemy = enemy_scene.instantiate()
	add_sibling(commander)
	
	# sets the resource of the commander
	commander.enemy_resource = _get_enemy_type_resource()
	
	# setting properties
	commander.extraction_pod = extraction_pod
	commander.size = (
		wave_resource.commander_start_size + 
		Global.sector_run_time * commander_size_ratio + 
		randf_range(0, wave_resource.commander_random_additional_size)
		)
	commander.scale *= commander.size
	commander.is_commander = true
	commander.sector_shield = sector_shield
	
	commander.global_position = _spawn_in_radius(
		random_spawn_node.global_position, 
		wave_resource.cluster_spawn_radius, 
		commander.size
	)
	commander.finish_loading()
	
	# Squad Cluster Spawning Loop
	for x in range(cluster_size):
		var new_enemy : BaseEnemy = enemy_scene.instantiate()
		add_sibling(new_enemy)
		
		new_enemy.enemy_resource = _get_enemy_type_resource()
		
		new_enemy.extraction_pod = extraction_pod
		new_enemy.sector_shield = sector_shield
		new_enemy.size = (
			wave_resource.start_size +
			Global.sector_run_time * normal_size_ratio +
			randf_range(-wave_resource.random_additional_size, wave_resource.random_additional_size)
			)
		new_enemy.scale *= new_enemy.size
		new_enemy.global_position = _spawn_in_radius(
			Vector3(
				commander.global_position.x,
				random_spawn_node.global_position.y,
				commander.global_position.z
				),
			wave_resource.enemy_spawn_radius,
			new_enemy.size,
			commander.size
		)
		new_enemy.finish_loading()


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


func _get_enemy_type_resource():
	var total_weight := 0
	
	for enemy_weight_info : EnemyWeight in wave_resource.enemies:
		total_weight += enemy_weight_info.weight
	
	var roll = randf() * total_weight
	
	for enemy_weight_info : EnemyWeight in wave_resource.enemies:
		roll -= enemy_weight_info.weight
		
		if roll <= 0:
			return DataRegistry.enemies[enemy_weight_info.enemy_name]


func _get_time_ratio(start_value: float, end_value: float) -> float:
	return (end_value - start_value) / wave_resource.end_time
