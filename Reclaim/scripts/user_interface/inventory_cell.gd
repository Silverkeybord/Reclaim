class_name inventory_cell
extends Control

const CELL_TEXTURE_KEY := "cell"

@export_group("values")
@export var item_resource : ItemData

@export_group("visuals")
@export var cell_texture : TextureRect
@export var item_texture : TextureRect
@export var amount_label : Label
@export var item_tip : CanvasLayer

var amount : int 


func setup() -> void:
	if Global.at_ship:
		amount = Global.ship_inventory[item_resource.tier][item_resource.key]
	else:
		amount = Global.sector_inventory[item_resource.tier][item_resource.key]
	
	amount_label.text = Global.return_amount_shorthand(amount)
	
	cell_texture.texture = Global.TIER_CONFIG[item_resource.tier][CELL_TEXTURE_KEY]
	
	var item_texture_path = item_resource.get_item_path()
	
	if FileAccess.file_exists(item_texture_path):
		item_texture.texture = load(item_texture_path)
	else:
		item_texture.texture = load(item_resource.NONE_ITEM)


func _on_mouse_entered() -> void:
	item_tip.show_itemtip(item_resource, amount)


func _on_mouse_exited() -> void:
	item_tip.hide_itemtip()
