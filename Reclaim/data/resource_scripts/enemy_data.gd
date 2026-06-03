class_name EnemyData
extends Resource

@export var key : String

## health points
@export var hp : int
## damage done to the barrier 
@export var damage : int
## meters per second toward the target
@export var speed : float

@export_group("Drops")
@export var min_drops : int = 1
@export var max_drops : int = 4

## must add to 100 for probability to work
@export var drop_table : Dictionary = {
	"dirt" : 0,
	"sand" : 0,
	"rock" : 0,
	"stick" : 0
}
