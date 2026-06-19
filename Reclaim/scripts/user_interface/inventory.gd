extends Control

@export var grid_container : GridContainer
@export var inventory_cell_scene : PackedScene


func _ready() -> void:
	Global.set_random_inventory()
	_load_inventory()


func _load_inventory() -> void:
	for teir in Global.inventory:
		for item in Global.inventory[teir]:
			if Global.inventory[teir][item] > 0:
				var new_cell : inventory_cell = inventory_cell_scene.instantiate()
				grid_container.add_child(new_cell)
				new_cell.item = item
				new_cell.teir = teir
				new_cell.amount = Global.inventory[teir][item]
				new_cell.setup()
