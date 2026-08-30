class_name CraftPinAmount
extends Panel

const PANEL_NAME := &"panel"

const LABEL_FORMAT := "%s/%s"
const GREEN_COLOR := Color("9BFF9B")
const RED_COLOR := Color("ff948bff")
const COLOR_A := 0.6

@export var glow_background_panel : Panel
@export var required_amount : int
@export var item_data : ItemData
@export var amount_label : Label
@export var item_texture : TextureRect

var amount : int


func _ready() -> void:
	set_process(false)
	
	if not item_data:
		return
	
	item_texture.texture = item_data.get_item_texture()
	
	amount = HelperFunctions.get_item_amount(item_data)
	amount_label.text = LABEL_FORMAT % [
		HelperFunctions.return_amount_shorthand(amount), 
		HelperFunctions.return_amount_shorthand(required_amount)
		]
	
	if Global.crafting_pin_open:
		set_process(true)
	
	var style : StyleBoxFlat = glow_background_panel.get_theme_stylebox(PANEL_NAME).duplicate()
	var color = Global.TIER_CONFIG[item_data.tier][Global.KEY_COLOR]
	style.bg_color = color
	style.bg_color.a = COLOR_A
	style.border_color = color
	style.border_color.a = 0
	glow_background_panel.add_theme_stylebox_override(PANEL_NAME, style)


func update_item_amount() -> void:
	amount = HelperFunctions.get_item_amount(item_data)
	amount_label.text = LABEL_FORMAT % [
		HelperFunctions.return_amount_shorthand(amount), 
		HelperFunctions.return_amount_shorthand(required_amount)
		]
	
	amount_label.modulate = GREEN_COLOR if (amount >= required_amount) else RED_COLOR


func get_craft_times() -> int:
	if not amount:
		return 0
	return floori(float(amount) / float(required_amount))
