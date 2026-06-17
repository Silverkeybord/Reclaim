class_name inventory_cell
extends Control

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
	print(cell_texture.texture)
	
