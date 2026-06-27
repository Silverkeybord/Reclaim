extends CanvasLayer

enum TABS {
	TURRETS,
	MODULES,
	RESOURCES
}

const ACTIVE_TURRETS_TAB := preload("res://2d_assets/crafting/active_turret_tab.png")
const ACTIVE_MODULES_TAB := preload("res://2d_assets/crafting/active_modules_tab.png")
const ACTIVE_RESOURCE_TAB := preload("res://2d_assets/crafting/active_resources_tab.png")
const INACTIVE_TURRETS_TAB := preload("res://2d_assets/crafting/inactive_turret_tab.png")
const INACTIVE_MODULES_TAB := preload("res://2d_assets/crafting/inactive_modules_tab.png")
const INACTIVE_RESOURCE_TAB := preload("res://2d_assets/crafting/inactive_resources_tab.png")

const CRAFT_CELL_SCENE := preload("res://scenes/user_interface/craft_cell.tscn")
const SECTION_SELECTION_SCENE := preload(
	"res://scenes/user_interface/crafting_selection_sections.tscn"
	)

const CRAFT_CELLS_GROUP := "craft_cells"
const REQUIRMENT_CELLS_GROUP := "requirment_cells"

const OPEN_ANIMATION := "open_crafting"
const CLOSE_ANIMATION := "close_crafting"

@export var crafting_animations : AnimationPlayer
@export var crafting_storage : PanelContainer

@export_group("Requirments")
@export var current_displayed_requirments : CraftData
@export var recipe_requirments_scene : PackedScene
@export var craft_name : Label
@export var image_background : PanelContainer
@export var requirement_image : TextureRect
@export var weight_stat : Label
@export var value_stat : Label
@export var amount_stat : Label
@export var craft_time_stat : Label
@export var description : Label
@export var requirments_hflow : HFlowContainer
@export var craft_button : Button
@export var craft_overlay : MarginContainer

@export_group("Crafting Tabs")
@export var turrets_tab : Button
@export var modules_tab : Button
@export var resources_tab : Button
@export var turrets_vbox : VBoxContainer
@export var modules_vbox : VBoxContainer
@export var resources_vbox : VBoxContainer
@export var turrets_tab_scroll : ScrollContainer
@export var modules_tab_scroll : ScrollContainer
@export var resources_tab_scroll : ScrollContainer

@onready var tab_vboxs : Dictionary = {
	Global.ITEM_TYPES.TURRET : turrets_vbox,
	Global.ITEM_TYPES.MODULE : modules_vbox,
	Global.ITEM_TYPES.RESOURCES : resources_vbox
}

var current_tab = TABS.TURRETS
var ship_level_requirments : Dictionary = {
	1 : {},
	2 : {},
	3 : {},
	4 : {},
	5 : {},
	6 : {},
	7 : {},
	8 : {},
}


func _ready() -> void:
	for recipe_key : String in DataRegistry.crafting:
		var item_key = DataRegistry.crafting[recipe_key].crafted_item.key
		var level = DataRegistry.crafting[recipe_key].required_ship_level
		
		ship_level_requirments[level][item_key] = DataRegistry.crafting[recipe_key]
	
	load_crafting()


func _process(_delta: float) -> void:
	if not Global.crafting_open:
		return
	
	if Input.is_action_just_pressed("interact"):
		open_or_close()


# UI control ================================================================
func open_or_close() -> void:
	if crafting_animations.is_playing():
		return
	
	Global.set_mouse_captured()
	
	if Global.crafting_open:
		close_crafting()
	else:
		open_crafting()


func open_crafting() -> void:
	Global.ui_open = true
	Global.crafting_open = true
	
	update_crafting_display()
	crafting_animations.play(OPEN_ANIMATION)


func close_crafting() -> void:
	Global.ui_open = false
	Global.crafting_open = false
	
	crafting_animations.play(CLOSE_ANIMATION)


# Loading and Crafting ======================================================
## crafts the item from the craft data given
func craft(craft_data : CraftData = current_displayed_requirments) -> void:
	var current_inventory = Global.get_current_inventory()
	
	
	for requirment : RequirementsTemplate in craft_data.requirements:
		current_inventory[requirment.item.tier][requirment.item.key] -= requirment.amount
	
	current_inventory[craft_data.crafted_item.tier][craft_data.crafted_item.key] += (
		craft_data.craft_amount
		)
	
	update_crafting_display()


## loads all crafting UI
func load_crafting() -> void:
	for ship_level in ship_level_requirments:
		if ship_level > Global.ship_level:
			break
		
		else:
			for recipe_key : String in ship_level_requirments[ship_level]:
				var recipe : CraftData = ship_level_requirments[ship_level][recipe_key]
				var item_type = recipe.crafted_item.type
				var tab_vbox = tab_vboxs[item_type]
				var section : CraftingSelection
				
				
				if tab_vbox.selection_sections[recipe.crafted_item.tier]:
					section = tab_vbox.selection_sections[recipe.crafted_item.tier]
					
				else:
					var new_selection_section : CraftingSelection = (
						SECTION_SELECTION_SCENE.instantiate()
						)
					new_selection_section.tier = recipe.crafted_item.tier
					tab_vbox.selection_sections[recipe.crafted_item.tier] = new_selection_section
					tab_vbox.add_child(new_selection_section)
					
					section = new_selection_section
					section.set_up()
				
				var new_craft_cell : CraftCell = CRAFT_CELL_SCENE.instantiate()
				new_craft_cell.craft_data = recipe
				new_craft_cell.add_to_group(CRAFT_CELLS_GROUP)
				new_craft_cell.crafting_menu = self
				section.hflow.add_child(new_craft_cell)


# gets everying to check their values
func update_crafting_display() -> void:
	if not Global.crafting_open:
		return
	
	var can_craft := true
	for cell : RecipeRequirement in get_tree().get_nodes_in_group(REQUIRMENT_CELLS_GROUP):
		if not cell.check_requirement():
			craft_overlay.visible = true
			can_craft = false
	
	craft_overlay.visible = not can_craft
	craft_button.disabled = not can_craft
	
	crafting_storage.update_storage()
	
	for cell : CraftCell in get_tree().get_nodes_in_group(CRAFT_CELLS_GROUP): 
		cell.check_requirements()


# Craft Selection and Requirments Controlling ===============================
func display_requirements_for(craft_data : CraftData, can_craft : bool) -> void:
	if not Global.crafting_open:
		return
	
	current_displayed_requirments = craft_data
	craft_name.text = Global.get_display_name(craft_data.crafted_item.key)
	requirement_image.texture = craft_data.crafted_item.get_item_texture()
	
	var style : StyleBoxFlat = image_background.get_theme_stylebox("panel").duplicate()
	style.bg_color = Global.TIER_CONFIG[craft_data.crafted_item.tier]["color"]
	image_background.add_theme_stylebox_override("panel", style)
	
	weight_stat.text = "Weight: " + Global.comma_number(craft_data.crafted_item.weight)
	value_stat.text = "Value: " + str(craft_data.crafted_item.value)
	amount_stat.text = "Amount: " + str(craft_data.craft_amount)
	craft_time_stat.text = "Craft Time: " + str(craft_data.craft_time)
	description.text = craft_data.description
	
	for cell in get_tree().get_nodes_in_group(REQUIRMENT_CELLS_GROUP):
		cell.queue_free()
	
	for requirment in craft_data.requirements:
		var new_requirment : RecipeRequirement = recipe_requirments_scene.instantiate()
		new_requirment.item_data = requirment.item
		new_requirment.amount_required = requirment.amount
		new_requirment.update_value()
		requirments_hflow.add_child(new_requirment)
		new_requirment.add_to_group(REQUIRMENT_CELLS_GROUP)
	
	craft_overlay.visible = not can_craft
	craft_button.disabled = not can_craft


# Tab Controlling ============================================================
func _change_to_tab(new_tab) -> void:
	if not Global.crafting_open:
		return
	
	current_tab = new_tab
	turrets_tab.icon = INACTIVE_TURRETS_TAB
	modules_tab.icon = INACTIVE_MODULES_TAB
	resources_tab.icon = INACTIVE_RESOURCE_TAB
	turrets_tab_scroll.visible = false
	modules_tab_scroll.visible = false
	resources_tab_scroll.visible = false
	
	match current_tab:
		TABS.TURRETS:
			turrets_tab.icon = ACTIVE_TURRETS_TAB
			turrets_tab_scroll.visible = true
			
		TABS.MODULES:
			modules_tab.icon = ACTIVE_MODULES_TAB
			modules_tab_scroll.visible = true
		
		TABS.RESOURCES:
			resources_tab.icon = ACTIVE_RESOURCE_TAB
			resources_tab_scroll.visible = true


func _on_turret_tab_button_pressed() -> void:
	_change_to_tab(TABS.TURRETS)


func _on_modules_tab_button_pressed() -> void:
	_change_to_tab(TABS.MODULES)


func _on_resourses_tab_button_pressed() -> void:
	_change_to_tab(TABS.RESOURCES)
