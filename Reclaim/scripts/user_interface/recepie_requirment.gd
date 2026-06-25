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


func _ready() -> void:
	Global.set_random_inventory()
	await get_tree().create_timer(2).timeout
	update_value()


func update_value() -> void:
	add_theme_stylebox_override(
		"panel", Global.TIER_CONFIG[item_data.tier]["style"]
		)
	item_image.texture = load(item_data.get_item_path())
	label.text = Global.return_amount_shorthand(amount_required) + " " + item_data.key
	check_requirment()


func check_requirment() -> void:
	var current_inventory : Dictionary = Global.get_current_inventory()
	
	if current_inventory[item_data.tier].has(item_data.key):
		if current_inventory[item_data.tier][item_data.key] >= amount_required:
			have_enough = true
		else:
			print("not enough")
			have_enough = false
	else:
		print("cant find")
		have_enough = false
	
	have_indication.texture = HAVE_INDICATIONS[have_enough]
