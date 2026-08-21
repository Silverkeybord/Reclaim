class_name EnemyData
extends Resource

const SPAWN_SIZES := {
	"very_small" : 0.7,
	"small" : 1,
	"medium" : 1.25,
	"big" : 1.5,
	"large" : 2,
	"ginormous" : 3,
}

const COMMANDER_ADDITIONAL_SIZE := 0.5

@export var key : String

## The scene of the enemy
@export var enemy_scene : PackedScene

## health points
@export var health : int
## damage done to the barrier 
@export var damage : int
## meters per second toward the target
@export var speed : float
## time inbetween each attack
@export var attack_interval : float = 2.5
## The size removed or added to an enemies spawn size percentage bassed
@export_range(0, 0.5, 0.05) var size_change := 0.0

@export_group("Drops")
@export var min_drops : int = 1
@export var max_drops : int = 3

## using a weight system its the raito of what drops to what
@export var drop_table : Array[DropWeight]
