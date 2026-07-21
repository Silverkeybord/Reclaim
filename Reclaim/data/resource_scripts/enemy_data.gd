class_name EnemyData
extends Resource

@export var key : String

## health points
@export var health : int
## damage done to the barrier 
@export var damage : int
## meters per second toward the target
@export var speed : float
## time inbetween each attack
@export var attack_interval : float = 2.5

@export_group("Drops")
@export var min_drops : int = 1
@export var max_drops : int = 3

## using a weight system its the raito of what drops to what
@export var drop_table : Array[DropWeight]
