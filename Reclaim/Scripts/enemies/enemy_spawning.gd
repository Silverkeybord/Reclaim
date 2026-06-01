extends Node3D

const SPAWN_MARKERS_GROUP : String = "enemy_spawn_markers"

var wave_data : Resource

var difficulty_mult : int

var start_spawn_rate : float
var end_spawn_rate : float
var spawn_rate_raito : float # the spawnrate in terms of time alive
var spawn_rate : float
var spawn_nodes : Array[Node]

var cluster_rate_raito : float # the cluster size in terms of time alive
var cluster_size : int

var wave_enemies : Dictionary

@export_group("enemies")
@export var enemy_scene : PackedScene

@export_group("in scene")
@export var spawn_timer : Timer

@export_group("map info")
## the target for spawned enemies
@export var extraction_pod : Node3D
## the map this is placed on
@export var map : String

@export var run_time := 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wave_data = GameData.wave[map]
	spawn_rate = wave_data.ssr
	spawn_rate_raito = (wave_data.ssr - wave_data.esr) / wave_data.end_time
	cluster_rate_raito = (wave_data.scs - wave_data.ecs) / wave_data.end_time
	
	spawn_nodes = get_tree().get_nodes_in_group(SPAWN_MARKERS_GROUP)
	
	spawn_timer.start()


func _process(delta: float) -> void:
	run_time += delta
	Global.sector_run_time = run_time


func _on_spawn_timer_timeout() -> void:
	cluster_size = wave_data.scs - (run_time * cluster_rate_raito)
	spawn_rate = wave_data.ssr - (run_time * spawn_rate_raito)
	spawn_timer.start(spawn_rate)
	
	if Global.enemies >= Global.MAX_SPHERES:
		return
	
	var random_spawn_node = spawn_nodes.pick_random()
	var commander = enemy_scene.instantiate()
	
	add_sibling(commander)
	commander.global_position = spawn_in_radius(
		random_spawn_node.global_position, wave_data.cluster_spawn_radius
		)
	
	commander.extraction_pod = extraction_pod
	commander.size = wave_data.commandar_size + randf_range(0, wave_data.cas)
	commander.scale *= commander.size
	commander.fin_loading()
	
	for x in range(cluster_size):
		var new_enemy = enemy_scene.instantiate()
		add_sibling(new_enemy)
		
		new_enemy.global_position = spawn_in_radius(
			commander.global_position, 
			wave_data.enemy_spawn_radius,
			commander.size
			)
		
		new_enemy.extraction_pod = extraction_pod
		new_enemy.size = randf_range(wave_data.smallest_size, wave_data.biggest_size)
		new_enemy.scale *= new_enemy.size
		new_enemy.fin_loading()


# Helper function to calculate a random XZ position within a given radius
func spawn_in_radius(
	center_position: Vector3, 
	max_radius: float, 
	min_radius : float = 0.0
	) -> Vector3:
	
	var radius = randf_range(min_radius, max_radius)
	var angle = randf_range(0, TAU)
	var x_offset = sin(angle) * radius
	var z_offset = cos(angle) * radius
	
	return center_position + Vector3(x_offset, 0, z_offset)
