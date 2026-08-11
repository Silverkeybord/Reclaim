class_name SpawnSection
extends Resource

## the time when this spawning pattern will start
@export var time := 0

## The time before the spawning starts
@export var breathing_room := 1

## time inbetween each spawn
@export var spawn_interval : float = 5.0

## Amount of enemies spawned per spawn interval (not including commanders)
@export var spawn_amount := 1

## If this is toggled this section will have commanders
@export var commanders := false

## If this is toggled this section will spawn enemies from every side
@export var swarm := false

@export_group("Scaling")
## Toggles if there is going to be linear spawnrate scaling in this section if not -1.0
@export var end_spawn_rate : float = -1.0

@export_group("")
## Weight systems for enemy span sizes
@export var spawn_sizes := {
	"very_small" : 1,
	"small" : 0,
	"medium" : 0,
	"big" : 0,
	"large" : 0,
	"gianormous" : 0,
}

## using a weight system like drops
@export var enemies : Array[EnemyWeight]
