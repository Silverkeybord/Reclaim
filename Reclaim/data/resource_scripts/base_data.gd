class_name BaseData
extends Resource

enum BASE_EFFECTS {
	NONE,
	COOLDOWN,
	SINGLE_SYNERGY,
	DUAL_SYNERGY
}

const BASE_EFFECTS_LOOKUP = {
	0 : "None",
	1 : "Cooldown",
	2 : "Single Synergy",
	3 : "Dual Synergy"
}

@export var key : String

@export var effect : BASE_EFFECTS = BASE_EFFECTS.NONE
