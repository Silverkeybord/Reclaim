extends Control

@export var flow_container : HFlowContainer
@export var inventory_cell_scene : PackedScene


func _ready() -> void:
	_load_inventory()


func _load_inventory() -> void:
	for teir in Global.inventory:
		for item in Global.inventory[teir]:
			if Global.inventory[teir][item] > 0:
				var new_cell : inventory_cell = inventory_cell_scene.instantiate()
				flow_container.add_child(new_cell)
				new_cell.item = item
				new_cell.teir = teir
				new_cell.amount = Global.inventory[teir][item]
				new_cell.setup()
