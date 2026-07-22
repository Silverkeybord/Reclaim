class_name StorageCell
extends Control

const CELLS_TEXTURE_KEY := "cells"
const RESOURCES_KEY := "resources"
const TURRETS_KEY := "turrets"
const MODULES_KEY := "modules"
const DEFAULT_AMOUNT := 0

@export_group("values")
@export var item_resource : ItemData

@export_group("visuals")
@export var cell_texture : TextureRect
@export var item_texture : TextureRect
@export var amount_label : Label
@export var item_tip : CanvasLayer
@export var resource_highlight_overlay : Panel
@export var full_highlight_overlay : Panel

var amount : int 


func setup() -> void:
	if not HelperFunctions.is_valid_item(item_resource):
		visible = false
		return
	
	update_amount()
	
	var textures : Dictionary = Global.TIER_CONFIG[item_resource.tier][CELLS_TEXTURE_KEY]
	var texture : Texture
	
	match item_resource.type:
		Global.ITEM_TYPES.RESOURCES:
			texture = textures[RESOURCES_KEY]
		Global.ITEM_TYPES.TURRET, Global.ITEM_TYPES.BASE:
			texture = textures[TURRETS_KEY]
		Global.ITEM_TYPES.MODULE:
			texture = textures[MODULES_KEY]
	
	cell_texture.texture = texture
	
	item_texture.texture = item_resource.get_item_texture()


func update_amount() -> void:
	if not HelperFunctions.is_valid_item(item_resource):
		amount = DEFAULT_AMOUNT
		visible = false
		return
	
	amount = HelperFunctions.get_item_amount(item_resource)
	amount_label.text = HelperFunctions.return_amount_shorthand(amount)
	
	# you can get booleans from this
	visible = amount > 0


func _on_mouse_entered() -> void:
	if not HelperFunctions.is_valid_item(item_resource):
		return
	
	if item_tip:
		item_tip.show_itemtip(item_resource, amount, item_resource.type)
	
	if item_resource.type == Global.ITEM_TYPES.RESOURCES:
		resource_highlight_overlay.visible = true
	else:
		full_highlight_overlay.visible = true


func _on_mouse_exited() -> void:
	if item_tip:
		item_tip.hide_itemtip()
	
	if not HelperFunctions.is_valid_item(item_resource):
		return
	
	if item_resource.type == Global.ITEM_TYPES.RESOURCES:
		resource_highlight_overlay.visible = false
	else:
		full_highlight_overlay.visible = false
