class_name inventory_cell
extends Control

const NO_ITEM_TEXTURE := preload("res://2d_assets/items/t1/none.png")
const CELL_TEXTURE_KEY := "cell"

@export_group("values")
@export var item : String
@export var amount : int
@export_range(1, 5) var teir : int

@export_group("visuals")
@export var cell_texture : TextureRect
@export var item_texture : TextureRect
@export var amount_label : Label


func setup() -> void:
	amount_label.text = Global.return_amount_shorthand(amount)
	cell_texture.texture = Global.RARITY_CONFIG[teir][CELL_TEXTURE_KEY]
	if item in GameData.drops:
		item_texture.texture = load(GameData.drops[item].item_texture)
	else:
		item_texture.texture = NO_ITEM_TEXTURE
