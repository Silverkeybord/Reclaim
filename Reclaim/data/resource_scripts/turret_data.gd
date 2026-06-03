class_name TurretData
extends Resource

enum RANGE_SHAPES {
	CYLNIDER,
	SPHERE
}


@export var key: String

@export var display_name: String
@export_range(1, 5) var tier: int = 1

@export_group("Basic Stats")
@export var damage: float
@export var cooldown: float
@export var turret_range: float
@export var range_shape : RANGE_SHAPES

@export_group("Ammo Types")
@export var ammo_types : Dictionary = {
	"basic" : true,
	"light" : true,
	"heavy" : false,
	"explosive" : false,
	"beam" : false,
	
}
@export_group("Recpie")
@export var recipe: Dictionary

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
	"ammo_efficiency" : true,
	"explosive_bullets" : false
}
