class_name WaveData
extends Resource

## key used to call the resourses
@export var key : String

## Start spawn rate
@export var ssr : float 
## End spawn rate
@export var esr : float 
## Start cluster size
@export var scs : int 
## End cluster size
@export var ecs : int 
## Commandar aditional size
@export var cas : float 
## the minimum size of a commandar
@export var commandar_size : float
## biggest size of normal enemies
@export var biggest_size : float
## smalest size of normal enemies
@export var smallest_size : float

## When the difficult maxes out
@export var end_time : int

## Multiplying base stats for harder areas
@export var difficulty_mult : float 

## offset range from the spawn markers of the whole spawned cluster
@export var cluster_spawn_radius : float
## offset range from the cluster commandar for each of the enemies
@export var enemy_spawn_radius : float

## dictionary of all posible spheres if its not 0 means they 
## dont appear and anything else means they are.
## TOTALS MUST ADD TO 100
@export var enemies : Dictionary = {
	"basic" : 0,
	"dirt" : 0,
	"wood" : 0,
	"stone" : 0,
	"leaf" : 0,
	"metal" : 0,
	"concrete" : 0,
	"glass" : 0,
	"water" : 0,
	"air" : 0,
	"earth" : 0,
	"fire" : 0,
	"dupe" : 0,
}
