class_name ModuleData
extends Resource

enum EFFECT_ENUM {
	ADDITIVE,
	SUBTRACTIVE,
	MULTIPLICATIVE,
	POWER,
	BULLET_EFFECT
}

const EFFECT_NAMES := {
	0 : "Additive",
	1 : "Subtractive",
	2 : "Multiplicative",
	3 : "Power",
	4 : "Bullet Effect"
}

@export var key : String

## tier
@export_range(1, 5) var tier := 1

## the module type
@export_enum(
	"damage",
	"overclock",
	"range",
	"modular_modules",
	"turbo_charge",
	"explosive rounds",
	"frost",
	"water",
	"wind",
	"fire",
	"earth",
	"light",
	"dark"
) var module : String = "damage"
## what type of effect the module has on the 
##  turret interger relation to each effect
@export var effect_type: EFFECT_ENUM = EFFECT_ENUM.ADDITIVE
## the measurement of the effect
@export var value : String
