class_name RecipeRequirement
extends PanelContainer

const HAVE_INDICATIONS : Dictionary = {
	false : preload("res://2d_assets/crafting/not_enough_resources.png"),
	true : preload("res://2d_assets/crafting/enough_resources.png")
}

@export var item_data : ItemData
@export var amount_required : int = 10
@export var have_enough : bool = false

@export var label : Label
@export var item_image : TextureRect
@export var have_indication : TextureRect


func update_value() -> void:
	name = item_data.key
	add_theme_stylebox_override(
		"panel", Global.TIER_CONFIG[item_data.tier]["style"]
		)
	item_image.texture = item_data.get_item_texture()
	label.text = (
		Global.return_amount_shorthand(amount_required) + 
		" " + Global.get_display_name(item_data.key)
		)
	check_requirement()


func check_requirement() -> bool:
	var current_inventory : Dictionary = Global.get_current_inventory()
	
	if current_inventory[item_data.tier].has(item_data.key):
		if current_inventory[item_data.tier][item_data.key] >= amount_required:
			have_enough = true
		else:
			have_enough = false
	else:
		have_enough = false
	
	have_indication.texture = HAVE_INDICATIONS[have_enough]
	return have_enough
