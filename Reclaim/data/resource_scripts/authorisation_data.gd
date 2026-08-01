class_name AuthorisationData


@export var key : String

## All authorsatoins
@export_enum(
	"ship_tier",
	"ship_capacity",
	"crafting_efficiency",
	"deployment_capacity",
	"turret_slots",
	"shield_strenth",
	"extraction_capacity",
	"weapon_authorisatoin",
	"turret_authorisation",
	"module_authorisatoin",
) var authorisation : String

## the type of upgrade
@export_enum(
	"stat_increase",
	"crafting_unlock",
) var upgrade_type : String = "stat_increase"


## the level of authorsatoin
@export var level : int = 1

## The required resources for this access
@export var requirments : Array[RequirementsTemplate]

## The amount of cubits required for this upgrade
@export var required_cubits : int = 0
