class_name Storage
extends Node

const INVENTORY_CELLS_SCENE : PackedScene = preload("res://scenes/user_interface/storage_cell.tscn")
const OPEN_ANIMATION := "open_storage"
const CLOSE_ANIMATION := "close_storage"
const SCROLL_AMOUNT := 50
const MIN_SCROLL := 0

const INTERACT_INPUT := "interact"

const MISSING_CELL_PARENT_ERROR := "Storage UI item parent is missing."

@export var item_tip : CanvasLayer
@export var item_parent : Node
@export var crafting_inventory : bool = false
@export var storage_animations : AnimationPlayer
@export var scroll_container : ScrollContainer

var displayed_cells : Dictionary = {}


func _ready() -> void:
	displayed_cells = load_all_cells(item_parent, INVENTORY_CELLS_SCENE, item_tip)
	update_storage()


static func load_all_cells(
	cell_parent : Node, 
	cell_scene : PackedScene, 
	scene_item_tip : CanvasLayer,
	extraction_ui : CanvasLayer = null
	) -> Dictionary:
	
	if cell_parent == null:
		push_error(MISSING_CELL_PARENT_ERROR)
		return {}
	
	var loaded_cells : Dictionary = {}
	
	# Sort all items by tier
	var all_items : Array = DataRegistry.items.values()
	all_items.sort_custom(func(a : ItemData, b : ItemData) -> bool:
		return a.tier < b.tier
	)
	
	for item : ItemData in all_items:
		if not HelperFunctions.is_valid_item(item):
			continue
		
		var new_cell : BaseStorageCell = cell_scene.instantiate()
		cell_parent.add_child(new_cell)
		new_cell.item_resource = item
		new_cell.item_tip = scene_item_tip
		new_cell.setup()
		new_cell.visible = false
		loaded_cells[item.key] = new_cell
		
		if extraction_ui:
			new_cell.extraction_ui = extraction_ui
	
	return loaded_cells


# just toggles visibility of the cell from the cell if there is more than 0 of that item
func update_storage() -> void:
	for item_key : String in displayed_cells:
		var cell : BaseStorageCell = displayed_cells[item_key]
		cell.update_amount()


func _input(event: InputEvent) -> void:
	if not Global.storage_open:
		return
	
	if event is InputEventMouseButton and event.pressed and not crafting_inventory and scroll_container:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				scroll_container.scroll_vertical = max(
					scroll_container.scroll_vertical - SCROLL_AMOUNT,
					MIN_SCROLL
				)
			MOUSE_BUTTON_WHEEL_DOWN:
				scroll_container.scroll_vertical += SCROLL_AMOUNT
	
	if Input.is_action_just_pressed(INTERACT_INPUT):
		open_or_close()


func open_or_close() -> void:
	if not crafting_inventory:
		if storage_animations.is_playing():
			return
	else:
		return
	
	if Global.storage_open:
		close_storage()
	else:
		open_storage()


func open_storage() -> void:
	Global.ui_open = true
	Global.storage_open = true
	update_storage()
	if not crafting_inventory:
		storage_animations.play(OPEN_ANIMATION)


func close_storage() -> void:
	Global.ui_open = false
	Global.storage_open = false
	if not crafting_inventory:
		storage_animations.play(CLOSE_ANIMATION)
