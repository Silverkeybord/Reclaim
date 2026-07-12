class_name BaseData
extends Resource

enum BASE_EFFECTS {
	NONE,
	COOLDOWN,
	SINGLE_SYNERGY,
	DUAL_SYNERGY
}

@export var key : String

@export var effect : BASE_EFFECTS = BASE_EFFECTS.NONE

@export var value : String
