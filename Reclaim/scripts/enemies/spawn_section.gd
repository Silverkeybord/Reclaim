class_name SpawnSection
extends Resource

## the time when this spawning pattern will start
@export var time := 0

## The time before the spawning starts
@export var breathing_room := 10

## time inbetween each spawn
@export var spawn_interval : float = 5.0

## Amount of enemies spawned per spawn interval (not including commanders)
@export var spawn_amount := 1

## If this is toggled this section will have commanders
@export var commanders := false

## If this is toggled this section will spawn enemies from every side
@export var swarm := false

@export_group("Wave Message")
## Message at the start of the section
@export var section_message : String

@export_group("Scaling")
## If not 0 will change the spawning rate to this value by the end of the section
@export var end_spawn_rate : float

## The ending amout of didtional enemies
@export var end_additional_enemy_amount : int = 0

@export_group("Randomness")
## The range of enemies that can be spawned ontop of the base amount
@export var random_additional_enemies : int = 0

## Negetive/min range of when an enemy can spawn 
@export var min_spawn_interval := 0.0

## Positive/max range of when an enemy can spawn
@export var max_spawn_interval := 0.0

@export_group("")
## Weight systems for enemy span sizes
@export var spawn_sizes := {
	"very_small" : 0,
	"small" : 1,
	"medium" : 0,
	"big" : 0,
	"large" : 0,
	"gianormous" : 0,
}

## using a weight system like drops
@export var enemies : Array[EnemyWeight]
