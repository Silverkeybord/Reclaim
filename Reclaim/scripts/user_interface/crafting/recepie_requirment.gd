class_name RecipeRequirement
extends PanelContainer

const PANEL_NAME := "panel"
const STYLE_KEY := "style"
const SLASH_TEXT := "/"
const HAVE_INDICATIONS : Dictionary = {
	false : preload("res://2d_assets/crafting/not_enough_resources.png"),
	true : preload("res://2d_assets/crafting/enough_resources.png")
}
const SPACE_TEXT := " "
const DEFAULT_CRAFT_MULT := 1

@export var item_data : ItemData
@export var amount_required : int
@export var have_enough : bool = false

@export var label : Label
@export var item_image : TextureRect
@export var have_indication : TextureRect


func update_value(craft_mult : int) -> void:
	if not HelperFunctions.is_valid_item(item_data):
		visible = false
		have_enough = false
		return
	
	if craft_mult == 0:
		craft_mult = DEFAULT_CRAFT_MULT
	
	var current_amount = HelperFunctions.get_item_amount(item_data)
	name = item_data.key
	add_theme_stylebox_override(
		PANEL_NAME, Global.TIER_CONFIG[item_data.tier][STYLE_KEY]
		)
	
	item_image.texture = item_data.get_item_texture()
	label.text = (
		HelperFunctions.return_amount_shorthand(current_amount) + 
		SLASH_TEXT + 
		HelperFunctions.return_amount_shorthand(amount_required * craft_mult) + 
		SPACE_TEXT + HelperFunctions.get_display_name(item_data.key)
		)


func check_requirement(craft_mult : int) -> bool:
	if not HelperFunctions.is_valid_item(item_data):
		have_enough = false
	else:
		have_enough = HelperFunctions.has_item_amount(item_data, amount_required * craft_mult)
	
	have_indication.texture = HAVE_INDICATIONS[have_enough]
	
	update_value(craft_mult)
	return have_enough
