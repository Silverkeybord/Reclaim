extends CanvasLayer

const AMOUNT_TEXT := "Amount : "
const VALUE_TEXT := "Value : "
const WEIGHT_TEXT := "Weight : "
const FIRE_RATE_TEXT := "Fire Rate : "
const DAMAGE_TEXT := "Damage : "
const RANGE_TEXT := "Range : "
const ABILITY_TEXT := "Ability : "
const EFFECT_TEXT := "Effect : "
const TIER_TEXT := "Tier : "

const X_TEXT := "x"
const SECONDS_TEXT := "s"
const METERS_TEXT := "m"

@export_group("Resources Tip", "resource_")
@export var resource_name_label : Label
@export var resource_value_label : Label
@export var resource_weight_label : Label
@export var resource_amount_label : Label

@export_group("Turrets Tip", "turret_")
@export var turret_name_label : Label
@export var turret_value_label : Label
@export var turret_weight_label : Label
@export var turret_fire_rate_label : Label
@export var turret_damage_label : Label
@export var turret_range_label : Label
@export var turret_ability_label : Label

@export_group("Resources Tip")

@export_group("Tips")
@export var resources_tip : TextureRect
@export var turrets_tip : TextureRect
@export var moduels_tip : TextureRect

var current_tip : TextureRect


func _ready() -> void:
	set_process(false)


func show_itemtip(item : ItemData, amount : int, type : int) -> void:
	print("show : ", Time.get_ticks_msec())
	set_process(true)
	match type:
		Global.ITEM_TYPES.RESOURCES:
			current_tip = resources_tip
			resources_tip.visible = true
			resource_name_label.text = Global.get_display_name(item.key)
			resource_value_label.text = VALUE_TEXT + str(item.value)
			resource_weight_label.text = WEIGHT_TEXT + str(item.weight)
			resource_amount_label.text = AMOUNT_TEXT + Global.comma_number(amount) + X_TEXT
		Global.ITEM_TYPES.TURRET:
			current_tip = turrets_tip
			turrets_tip.visible = true
			turret_name_label.text = Global.get_display_name(item.key)
			turret_value_label.text = VALUE_TEXT + str(item.value)
			turret_weight_label.text = WEIGHT_TEXT + str(item.weight)
			
			var turret_info : TurretData = DataRegistry.turrets[item.key]
			
			turret_ability_label.text = ABILITY_TEXT + turret_info.ability
			turret_damage_label.text = (
				DAMAGE_TEXT + Global.return_amount_shorthand(turret_info.damage))
				
			turret_fire_rate_label.text = (
				FIRE_RATE_TEXT + str(turret_info.fire_rate) + SECONDS_TEXT)
			
			turret_range_label.text = (
				RANGE_TEXT + str(round(turret_info.turret_range)) + METERS_TEXT)
		Global.ITEM_TYPES.MODULE:
			current_tip = moduels_tip
	
	visible = true


func hide_itemtip() -> void:
	visible = false
	for tip in get_children():
		tip.visible = false


func _process(_delta : float) -> void:
	current_tip.position = get_viewport().get_mouse_position() + Vector2(0, 0)
