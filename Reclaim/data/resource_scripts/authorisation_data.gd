extends Resource
class_name AuthorisationData

const NO_TEXTURE_ICON := preload("res://2d_assets/council_authorisation/no_icon.png")

@export var key : String

## the type of upgrade/a classed effect
@export_enum(
	"stat_increase",
	"crafting_unlock",
	"ship_level"
) var upgrade_type : String = "stat_increase"

## the icon relating to the authority
@export var icon : Texture

## the max level this authority goes up to
@export var max_level : int = 1

## An array that holds all the levels and requirments using authorisation level template
@export var levels : Array[AuthorisationLevel]


func get_icon() -> Texture:
	if icon:
		return icon
	return NO_TEXTURE_ICON
