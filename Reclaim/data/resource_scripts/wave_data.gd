class_name WaveData
extends Resource

@export var key : String

## Information about what enemies spawn, when, where, commanders, ect
@export var spawning : Array[SpawnSection]

## The spawning pattern when the sector is cleared
@export var clear_spawning : SpawnSection
