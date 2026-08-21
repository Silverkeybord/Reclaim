class_name WaveData
extends Resource

const INDEX_TIME := 0
const INDEX_IS_BREATHING := 1

@export var key : String

## Information about what enemies spawn, when, where, commanders, ect
@export var spawning : Array[SpawnSection]

## The time when the sector is cleared
@export var end_time : float

## The spawning pattern when the sector is cleared
@export var clear_spawning : SpawnSection

## retuns the times of breathing time and wave time
func return_wave_stages() -> Array[Array]:
	var wave_stages : Array[Array]
	
	for spawn_section : SpawnSection in spawning:
		if not spawn_section:
			continue
		
		if spawn_section.breathing_room:
			wave_stages.append([spawn_section.time, true])
			wave_stages.append([spawn_section.time + spawn_section.breathing_room, false])
		else:
			wave_stages.append([spawn_section.time, true])
	
	return wave_stages


## returns the intervals of each wave
func return_wave_times() -> Array[float]:
	var wave_times : Array[float]
	
	for spawn_section : SpawnSection in spawning:
		wave_times.append(spawn_section.time)
	
	wave_times.append(end_time)
	
	return wave_times
