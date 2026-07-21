class_name WaveData
extends Resource

@export var key : String

@export_group("Spawn Rates", "spawn_")
@export var spawn_start_interval : float
@export var spawn_end_interval : float
@export var spawn_clear_interval : float = 10.0

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
## random aditional size to all non commanders
@export var random_aditional_size : float = 0.2
## the max distance from the spawn marker the commander will spawn at
@export var cluster_spawn_radius : float
## the max distance form the commander the normal enemies will spawn at
@export var enemy_spawn_radius : float

@export_group("Wave Info")
## The time you need to survive to clear a sector
@export var end_time : float
## using a weight system like drops
@export var enemies : Array[EnemyWeight]
