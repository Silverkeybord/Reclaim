extends PanelContainer

const HAVE_INDICATIONS : Dictionary = {
	false : preload("res://2d_assets/crafting/not_enough_resources.png"),
	true : preload("res://2d_assets/crafting/enough_resources.png")
}

const TEIR_STYLES : Dictionary = {
	1 : preload("res://other_assets/crafting_styles/t1_recepie_requirment.tres"),
	2 : preload("res://other_assets/crafting_styles/t2_recepie_requirment.tres"),
	3 : preload("res://other_assets/crafting_styles/t3_recepie_requirment.tres"),
	4 : preload("res://other_assets/crafting_styles/t4_recepie_requirment.tres"),
	5 : preload("res://other_assets/crafting_styles/t5_recepie_requirment.tres")
}


@export var item : String = "scrap"
@export var amount_required : int = 10
@export var have_enough : bool = false

@export var label : Label
@export var item_image : TextureRect
@export var have_indication : TextureRect


func _ready() -> void:
	await get_tree().create_timer(2).timeout
	update_value()



func update_value() -> void:
	add_theme_stylebox_override("panel", TEIR_STYLES[DataRegistry.items[item].teir])
	item_image.texture = load(DataRegistry.items[item].get_item_path())
	label.text = Global.return_amount_shorthand(amount_required) + " " + item
	check_requirment()


func check_requirment() -> void:
	var current_inventory : Dictionary
	if Global.at_ship:
		current_inventory = Global.ship_inventory
	else:
		current_inventory = Global.sector_inventory
	
	if current_inventory.has(item):
		if current_inventory[item] >= amount_required:
			have_enough = true
		else:
			have_enough = false
	else:
		have_enough = false
	
	have_indication.texture = HAVE_INDICATIONS[have_enough]
