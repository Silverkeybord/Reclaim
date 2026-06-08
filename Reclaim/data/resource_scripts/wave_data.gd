class_name WaveData
extends Resource

@export var key : String

@export_group("Spawn Rates", "spawn_")
@export var spawn_start_rate : float
@export var spawn_end_rate : float
@export var spawn_clear_rate : float = 10.0

@export_group("Cluster Sizes", "cluster_")
@export var cluster_start_size : int
@export var cluster_end_size : int

@export_group("Commander Settings", "commander_")
## The minimum base size of a commander
@export var commander_start_size : float = 2.0
## The max base size of a commander
@export var commander_end_size : float = 3.0
## The random additional size added to differentiate from others
@export var commander_random_additional_size : float = 0.5

@export_group("Enemy Settings")
## start base size of all non commanders at the start of a sector
@export var start_size : float = 1
## end base size of all non commanders at the end of clearing a sector
@export var end_size : float = 1.3
@export var random_aditional_size : float = 0.2
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
