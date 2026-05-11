extends Node3D

const MIN_SPAWN_DISTANCE := 80
const MAX_SPAWN_DISTANCE := 100

@export_group("in scene")
@export var spawn_timer : Timer

@export_group("map info")
@export var spawn_nodes : Marker3D
@export var map : String
@export var difficulty : int
@export var spawn_rate : int



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
