class_name WaveData
extends Resource

@export var key : String

@export_group("Spawn Rates", "spawn_")
@export var spawn_start_rate : float
@export var spawn_end_rate : float

@export_group("Cluster Sizes", "cluster_")
@export var cluster_start_size : int
@export var cluster_end_size : int

@export_group("Commander Settings", "commander_")
## The minimum base size of a commander
@export var commander_size : float
## The random additional size added to differentiate from others
@export var commander_additional_size : float

@export_group("Enemy Settings")
@export var smallest_size : float
@export var biggest_size : float
@export var cluster_spawn_radius : float
@export var enemy_spawn_radius : float

@export_group("Wave Info")
@export var end_time : float
## Must add to 100
@export var enemies : Dictionary = {
	"basic" : 100,
	"dirt" : 0,
	"sand" : 0,
	"water" : 0
}
