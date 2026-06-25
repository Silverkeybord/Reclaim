extends Node

@export var item_tip : CanvasLayer
@export var item_parent : Node
const inventory_cell_scene : PackedScene = preload("res://scenes/user_interface/inventory_cell.tscn")


func _ready() -> void:
	Global.set_random_inventory()
	_load_inventory()


func _load_inventory() -> void:
	var current_inventory : Dictionary
	
	if Global.at_ship:
		current_inventory = Global.ship_inventory
	else:
		current_inventory = Global.sector_inventory
	
	for teir in current_inventory:
		for item in current_inventory[teir]:
			if current_inventory[teir][item] > 0:
				var new_cell : inventory_cell = inventory_cell_scene.instantiate()
				item_parent.add_child(new_cell)
				new_cell.item_resource = DataRegistry.items[item]
				new_cell.item_tip = item_tip
				new_cell.setup()
