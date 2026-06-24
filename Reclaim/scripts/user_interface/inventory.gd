extends CanvasLayer

@export var grid_container : GridContainer
@export var inventory_cell_scene : PackedScene


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
				grid_container.add_child(new_cell)
				new_cell.item = item
				new_cell.teir = teir
				new_cell.amount = current_inventory[teir][item]
				new_cell.setup()
	
