extends CanvasLayer

const ITEMTIP_OFFSET := Vector2(16, -16)

const AMOUNT_TEXT := "Amount : "
const VALUE_TEXT := "Value : "
const WEIGHT_TEXT := "Weight : "
const FIRE_RATE_TEXT := "Fire Rate : "
const DAMAGE_TEXT := "Damage : "
const RANGE_TEXT := "Range : "
const ABILITY_TEXT := "Ability : "
const EFFECT_TEXT := "Effect : "
const TIER_TEXT := "Tier : "
const STAT_TEXT := "Stat : "
const BUILD_NAME_FORMAT := "- %s -"
const X_TEXT := "x"
const SECONDS_TEXT := " s"
const METERS_TEXT := "m"

@export var item_control : Control

@export_group("Resources Tip")
@export var resource_name_label : Label
@export var resource_value_label : Label
@export var resource_weight_label : Label
@export var resource_amount_label : Label

@export_group("Turrets Tip")
@export var turret_name_label : Label
@export var turret_value_label : Label
@export var turret_weight_label : Label
@export var turret_fire_rate_label : Label
@export var turret_damage_label : Label
@export var turret_range_label : Label
@export var turret_ability_label : Label

@export_group("Module Tip")
@export var module_name_label : Label
@export var module_effect_label : Label
@export var module_stat_label : Label
@export var module_weight_label : Label
@export var module_tier_label : Label

@export_group("Base Tip")
@export var base_name_label : Label
@export var base_effect_label : Label
@export var base_value_label : Label
@export var base_weight_label : Label

@export_group("Tips")
@export var resources_tip : TextureRect
@export var turrets_tip : TextureRect
@export var moduels_tip : TextureRect
@export var base_tip : TextureRect

var current_tip : TextureRect


func _ready() -> void:
	set_process(false)


func show_itemtip(item : ItemData, amount : int, type : int) -> void:
	set_process(true)
	match type:
		Global.ITEM_TYPES.RESOURCES:
			current_tip = resources_tip
			resources_tip.visible = true
			resource_name_label.text = HelperFunctions.get_display_name(item.key)
			resource_value_label.text = VALUE_TEXT + str(item.value)
			resource_weight_label.text = WEIGHT_TEXT + str(item.weight)
			resource_amount_label.text = AMOUNT_TEXT + HelperFunctions.comma_number(amount) + X_TEXT
			
		Global.ITEM_TYPES.TURRET:
			current_tip = turrets_tip
			turrets_tip.visible = true
			turret_name_label.text = BUILD_NAME_FORMAT % HelperFunctions.get_display_name(item.key)
			turret_value_label.text = VALUE_TEXT + str(item.value)
			turret_weight_label.text = WEIGHT_TEXT + str(item.weight)
			
			if not DataRegistry.turrets.has(item.key):
				return
			
			var turret_info : TurretData = DataRegistry.turrets[item.key]
			
			turret_ability_label.text = ABILITY_TEXT + turret_info.ability
			turret_damage_label.text = (
				DAMAGE_TEXT + HelperFunctions.return_amount_shorthand(turret_info.damage))
				
			turret_fire_rate_label.text = (
				FIRE_RATE_TEXT + str(turret_info.get_firerate()) + SECONDS_TEXT)
			
			turret_range_label.text = (
				RANGE_TEXT + str(round(turret_info.turret_range)) + METERS_TEXT)
			
		Global.ITEM_TYPES.MODULE:
			current_tip = moduels_tip
			moduels_tip.visible = true
			module_name_label.text = BUILD_NAME_FORMAT % HelperFunctions.get_display_name(item.key)
			var module : ModuleData = DataRegistry.modules[item.key]
			module_effect_label.text = EFFECT_TEXT + HelperFunctions.get_display_name(module.module)
			module_stat_label.text = STAT_TEXT + module.stat
			module_weight_label.text = WEIGHT_TEXT + str(item.weight)
			module_tier_label.text = TIER_TEXT + str(item.tier)
		
		Global.ITEM_TYPES.BASE:
			current_tip = base_tip
			base_tip.visible = true
			base_name_label.text = HelperFunctions.get_display_name(item.key)
			var base : BaseData = DataRegistry.bases[item.key]
			base_effect_label.text = EFFECT_TEXT + base.BASE_EFFECTS_LOOKUP[base.effect]
			base_value_label.text = VALUE_TEXT + str(item.value)
			base_weight_label.text = WEIGHT_TEXT + str(item.weight)
	
	visible = true


func hide_itemtip() -> void:
	visible = false
	for tip in item_control.get_children():
		tip.visible = false


func _process(_delta : float) -> void:
	item_control.position = get_viewport().get_mouse_position() + ITEMTIP_OFFSET
