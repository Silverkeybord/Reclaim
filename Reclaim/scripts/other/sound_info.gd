class_name SoundInfo
extends Resource

@export var stream : AudioStream

## the furthest distance you can hear the sound
@export var max_distance : int = 20
## the maximum value of decibels from -24 to 6
@export_range(-24, 6) var max_db = 2
## the base volume
@export_range(-80, 80) var volume: int
