class_name StorageCell
extends Control

const CELL_TEXTURE_KEY := "cell"

@export_group("values")
@export var item_resource : ItemData

@export_group("visuals")
@export var cell_texture : TextureRect
@export var item_texture : TextureRect
@export var amount_label : Label
@export var item_tip : CanvasLayer
@export var highlight_overlay : Panel

var amount : int 


func setup() -> void:
	update_amount()
	
	cell_texture.texture = Global.TIER_CONFIG[item_resource.tier][CELL_TEXTURE_KEY]
	
	item_texture.texture = item_resource.get_item_texture()


func update_amount() -> void:
	var inventory = Global.ship_inventory if Global.at_ship else Global.sector_inventory
	# If returned value dosen't exist return 0
	amount = inventory[item_resource.tier].get(item_resource.key, 0)
	amount_label.text = Global.return_amount_shorthand(amount)
	
	# you can get booleans from this
	visible = amount > 0


func _on_mouse_entered() -> void:
	item_tip.show_itemtip(item_resource, amount)
	highlight_overlay.visible = true


func _on_mouse_exited() -> void:
	item_tip.hide_itemtip()
	highlight_overlay.visible = false
