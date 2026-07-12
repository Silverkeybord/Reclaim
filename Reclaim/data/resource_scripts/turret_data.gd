class_name TurretData
extends Resource

enum RANGE_SHAPES {
	CYLNIDER,
	SPHERE
}

@export var key: String

@export_range(1, 5) var tier: int = 1

@export_group("Basic Stats")
## damage done to enemies
@export var damage: float
## time inetween each shot
@export var cooldown: float
## the radius in meters of the targeting area
@export var turret_range: float
## the shape of the range are
@export var range_shape : RANGE_SHAPES
@export_enum(
	"none",
	"burning",
	"freezing",
	"shock",
	"blinding",
	"wet",
	"poison",
) var ability := "none"

@export_group("Synergy Tags")
## if these turrets are next to the turret the turret will be boosted
@export var synergy_tags: Array[String]

@export_group("Targetable Enemies")
## enemy types the turret can target
@export var targetable_enemies : Dictionary = {
	"ground" : true,
	"air" : false,
	"hidden" : false,
}

@export_group("Allowed Modules")
## modules that can be applyed to this turret
@export var allowed_modules : Dictionary = {
	"damage" : true,
	"overclock" : true,
	"range" : true,
	"modular_modules" : true,
	"turbo_charge" : true,
	"frost" : true,
	"explosive_bullets" : false
}

@export_group("Sounds")
## one sould will be played form this array when this turret shoots
@export var shooting_sound : Array[SoundInfo]


@export_group("Critical Stats")
## probablity of a crit
@export_range(0, 1, 0.01) var cirt_rate : float
## damge multiplier on a successful crit
@export_range(1, 5, 0.1) var critical_multiplier : float = 1.5


func get_firerate() -> float:
	return 1 / cooldown

func get_damage_per_second() -> float:
	return damage * (1 / cooldown)


func get_critical() -> float:
	if randf() < cirt_rate:
		return true
	else:
		return false
