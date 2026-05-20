class_name WaveData
extends Resource

@export var map : String
@export var start_spawn_rate : float
@export var end_spawn_rate : float
@export var biggest_size : float
@export var smallest_size : float
@export var end_time : int
@export var difficulty_mult : float
@export var wave_progression : Dictionary = {
	int(0) : {
		"enemies" : [],
		"cluster_size" : 0
	},
}
