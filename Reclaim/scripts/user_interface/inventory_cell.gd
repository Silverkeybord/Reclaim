class_name inventory_cell
extends Control

const CELL_TEXTURE_KEY := "cell"

@export_group("values")
@export var item : String
@export var amount : int
@export_range(1, 5) var teir : int
@export var resourse : DropData

@export_group("visuals")
@export var cell_texture : TextureRect
@export var item_texture : TextureRect
@export var amount_label : Label


func setup() -> void:
	if item in DataRegistry.drops:
		resourse = DataRegistry.drops[item]
	
	amount_label.text = Global.return_amount_shorthand(amount)
	cell_texture.texture = Global.RARITY_CONFIG[teir][CELL_TEXTURE_KEY]
	
	if item in DataRegistry.drops:
		var item_texture_path : String = (
			resourse.ITEM_TEXTURE_PATH + 
			str(resourse.rarity) +
			resourse.SLASH +
			resourse.key + 
			resourse.PNG_TYPE
		)
		
		item_texture.texture = load(item_texture_path)
	
	else:
		item_texture.texture = load(resourse.NONE_ITEM)
