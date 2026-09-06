class_name CraftingUI
extends UserInterfaceMenu

enum TABS {
	TURRETS,
	MODULES,
	RESOURCES
}

const COLOR_KEY := "color"
const PANEL_OVERRIDE_KEY := "panel"

const ERR_INVALID_RECIPE := "Invalid crafting recipe skipped: %s" 
const ERR_INVALID_SHIP_LEVEL := "Crafting recipe has invalid ship level: %s"

const ACTIVE_TURRETS_TAB := preload("res://2d_assets/crafting/active_turret_tab.png")
const ACTIVE_MODULES_TAB := preload("res://2d_assets/crafting/active_modules_tab.png")
const ACTIVE_RESOURCE_TAB := preload("res://2d_assets/crafting/active_resources_tab.png")
const INACTIVE_TURRETS_TAB := preload("res://2d_assets/crafting/inactive_turret_tab.png")
const INACTIVE_MODULES_TAB := preload("res://2d_assets/crafting/inactive_modules_tab.png")
const INACTIVE_RESOURCE_TAB := preload("res://2d_assets/crafting/inactive_resources_tab.png")

const CRAFT_CELL_SCENE := preload("res://scenes/user_interface/crafting/craft_cell.tscn")
const SECTION_SELECTION_SCENE := preload(
	"res://scenes/user_interface/crafting/crafting_selection_sections.tscn"
	)

const CRAFT_QUEUE_SCENE := preload("res://scenes/user_interface/crafting/craft_queue_item.tscn")

const GROUP_CRAFT_CELLS := &"craft_cells"
const GROUP_CRAFT_QUEUE := &"craft_queue_items"
const GROUP_REQUIREMENT_CELLS := &"requirment_cells"
const GROUP_PLAYER := &"player"

const DPS_LABEL_PREFIX := "DPS : "
const ABILITY_LABEL_PREFIX := "Ability : "
const AMOUNT_LABEL_PREFIX := "Amount: "
const CRAFT_TIME_LABEL_PREFIX := "Craft Time: "

const CLOSE_UI_INPUT := "close_ui"

const RECIPE_PIN_NORMAL_COLOR := Color(0.743, 0.743, 0.743, 1.0)
const RECIPE_PIN_PINED_COLOR := Color(0.58, 1.0, 0.5, 1.0)

const MAX_CRAFT_QUEUE := 5

const CRAFT_ONE := 1
const CRAFT_FIVE := 5
const CRAFT_TWENTY_FIVE := 25
const CRAFT_MAX := 0

# Tween Pram
const TWEEN_DURATION := 0.8
const SHOW_POS := Vector2(0, 0)
const HIDE_POS := Vector2(0, -720)

@export var ui_root : MarginContainer
@export var craft_queue_vbox : VBoxContainer

@export_group("Recpie Pinning")
@export var craft_pin_texture : TextureRect
@export var recpie_pinning : RecpiePinning

@export_group("Requirments")
@export var current_displayed_requirments : CraftData
@export var recipe_requirments_scene : PackedScene
@export var craft_name : Label
@export var image_background : PanelContainer
@export var requirement_image : TextureRect
@export var requirments_hflow : HFlowContainer
@export var craft_button : Button
@export var craft_overlay : MarginContainer

@export_subgroup("Requirment Text")
@export var amount_stat : Label
@export var craft_time_stat : Label
@export var dps_stat : Label
@export var ability_stat : Label
@export var description : RichTextLabel

@export_subgroup("Craft Mults")
@export var one_times : Button
@export var five_times : Button
@export var twentyfive_times : Button
@export var max_times : Button

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
	Global.ITEM_TYPES.BASE : turrets_vbox,
	Global.ITEM_TYPES.MODULE : modules_vbox,
	Global.ITEM_TYPES.RESOURCES : resources_vbox
}
@onready var button_mults : Dictionary ={
	one_times : CRAFT_ONE,
	five_times : CRAFT_FIVE,
	twentyfive_times : CRAFT_TWENTY_FIVE,
	max_times : CRAFT_MAX
}
@onready var current_mult_pressed : Button = one_times
@onready var player : Player = get_tree().get_first_node_in_group(GROUP_PLAYER)

var can_craft_current : bool = false
var craft_mult : int = 1
var max_mult : int = 0
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
	set_process(false)
	description.get_v_scroll_bar().visible = false
	
	for recipe_key : String in DataRegistry.crafting:
		var recipe : CraftData = DataRegistry.crafting[recipe_key]
		if not _is_valid_recipe(recipe):
			push_error(ERR_INVALID_RECIPE % recipe_key)
			continue
		
		var item_key = recipe.crafted_item.key
		var level = recipe.required_ship_level
		if not ship_level_requirments.has(level):
			push_error(ERR_INVALID_SHIP_LEVEL % recipe_key)
			continue
		
		ship_level_requirments[level][item_key] = recipe
	
	load_crafting()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(CLOSE_UI_INPUT):
		close_ui()


# UI control ================================================================
func open_ui() -> void:
	if move_tween_playing:
		return
	
	_set_open_or_close(true)
	update_crafting_display()


func close_ui() -> void:
	if move_tween_playing:
		return
	
	_set_open_or_close(false)


func _set_open_or_close(toggle : bool) -> void:
	hide_or_show_tween(
		ui_root,
		TWEEN_DURATION,
		SHOW_POS if toggle else HIDE_POS,
		toggle
		)
	
	
	Global.ui_open = toggle
	Global.crafting_open = toggle
	set_open_timescale(toggle)
	set_process(toggle)
	HelperFunctions.set_mouse_captured(true, not toggle)


# Loading and Crafting ======================================================
## crafts the item from the craft data given
func craft(from_cell = false) -> void:
	var craft_data : CraftData = current_displayed_requirments
	
	if not can_craft_current or not current_displayed_requirments:
		return
	
	var resulting_craft_mult : int
	
	if from_cell:
		resulting_craft_mult = CRAFT_ONE
	else:
		resulting_craft_mult = craft_mult if not max_mult else max_mult
	
	_queue_craft(craft_data, resulting_craft_mult)
	
	# removing the resources for crafting that item
	for requirment : RequirementsTemplate in craft_data.requirements:
		HelperFunctions.remove_item_from_storage(
			requirment.item, 
			requirment.amount * resulting_craft_mult
			)
		
		player.item_notif_controller.add_notif(
			requirment.item, -requirment.amount * resulting_craft_mult
			)
	
	update_crafting_display()


# Creates a new craft queue or adds to the last if the same
func _queue_craft(craft_data : CraftData, craft_amount : int) -> void:
	var queued_items: Array = get_tree().get_nodes_in_group(GROUP_CRAFT_QUEUE)
	
	if queued_items:
		var last_item := queued_items.back() as CraftQueueItem
		
		if last_item and last_item.craft_data == craft_data:
			if not last_item.is_queued_for_deletion():
				last_item.amount += craft_amount
				last_item._set_amount_label()
				return
	
	var new_queue_item: CraftQueueItem = CRAFT_QUEUE_SCENE.instantiate()
	
	new_queue_item.craft_data = craft_data
	new_queue_item.amount = craft_amount
	new_queue_item.crafting_ui = self
	new_queue_item.item_notif_controller = player.item_notif_controller
	
	new_queue_item.add_to_group(GROUP_CRAFT_QUEUE)
	craft_queue_vbox.add_child(new_queue_item)
	
	if queued_items.is_empty() or queued_items[0].is_queued_for_deletion():
		new_queue_item.start_craft()


# Checks if the removed or finished item is in first slot and then starts the next if there is one
func queue_next() -> void:
	var queued_items = get_tree().get_nodes_in_group(GROUP_CRAFT_QUEUE)
	
	update_crafting_display()
	
	if queued_items.size() == 0:
		return
	
	var first_queued_item : CraftQueueItem = queued_items[0]
	
	if first_queued_item.craft_timer.is_stopped():
		first_queued_item.start_craft()


## loads all crafting UI bassed on ship level
func load_crafting() -> void:
	for ship_level in ship_level_requirments:
		if ship_level > Global.ship_level:
			break
		
		else:
			for recipe_key : String in ship_level_requirments[ship_level]:
				var recipe : CraftData = ship_level_requirments[ship_level][recipe_key]
				var item_type = recipe.crafted_item.type
				if not tab_vboxs.has(item_type):
					continue
				
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
				new_craft_cell.add_to_group(GROUP_CRAFT_CELLS)
				new_craft_cell.crafting_menu = self
				section.hflow.add_child(new_craft_cell)


# gets everying to check their values
func update_crafting_display() -> void:
	if not Global.crafting_open:
		return
	
	var craft_requirments : Array[RequirementsTemplate]
	var max_crafting_amounts : Array[int]
	
	if craft_mult == 0 and current_displayed_requirments:
		craft_requirments = current_displayed_requirments.requirements
		
		for requirment : RequirementsTemplate in craft_requirments:
			var item_amount = HelperFunctions.get_item_amount(requirment.item)
			max_crafting_amounts.append(floori(float(item_amount) / float(requirment.amount)))
		
		max_mult = max_crafting_amounts.min()
	
	# gets all the cells to check if there is enough and highlights craft button
	can_craft_current = true
	
	if get_tree().get_nodes_in_group(GROUP_CRAFT_QUEUE).size() > MAX_CRAFT_QUEUE:
		can_craft_current = false
	
	if can_craft_current:
		for cell : RecipeRequirement in get_tree().get_nodes_in_group(GROUP_REQUIREMENT_CELLS):
			if not cell.check_requirement(craft_mult if craft_mult else max_mult):
				craft_overlay.visible = true
				can_craft_current = false
	
	craft_overlay.visible = not can_craft_current
	craft_button.disabled = not can_craft_current
	
	if not current_displayed_requirments:
		craft_overlay.visible = true
	
	for cell : CraftCell in get_tree().get_nodes_in_group(GROUP_CRAFT_CELLS): 
		cell.check_requirements()


# checks if the recipe is valid
func _is_valid_recipe(craft_data : CraftData) -> bool:
	if craft_data == null or not HelperFunctions.is_valid_item(craft_data.crafted_item):
		return false
	
	for requirment : RequirementsTemplate in craft_data.requirements:
		if (
			requirment == null
			or not HelperFunctions.is_valid_item(requirment.item)
		):
			return false
	
	return true


# checks if the current displayed crafting requirments can be crafted
func _can_craft(craft_data : CraftData) -> bool:
	if not _is_valid_recipe(craft_data):
		return false
	
	if get_tree().get_nodes_in_group(GROUP_CRAFT_QUEUE).size() > MAX_CRAFT_QUEUE:
		return false
	
	for requirment : RequirementsTemplate in craft_data.requirements:
		if not HelperFunctions.has_item_amount(requirment.item, requirment.amount):
			return false
	
	return true


# Craft Selection and Requirments Controlling ===============================
func display_requirements_for(craft_data : CraftData, can_craft : bool) -> void:
	
	if not Global.crafting_open or not _is_valid_recipe(craft_data):
		return
	
	current_displayed_requirments = craft_data
	craft_name.text = HelperFunctions.get_display_name(craft_data.crafted_item.key)
	requirement_image.texture = craft_data.crafted_item.get_item_texture()
	
	var style : StyleBoxFlat = image_background.get_theme_stylebox(PANEL_OVERRIDE_KEY).duplicate()
	style.bg_color = Global.TIER_CONFIG[craft_data.crafted_item.tier][COLOR_KEY]
	image_background.add_theme_stylebox_override(PANEL_OVERRIDE_KEY, style)
	
	match craft_data.crafted_item.type:
		Global.ITEM_TYPES.RESOURCES:
			show_stat_labels([amount_stat, craft_time_stat])
			amount_stat.text = AMOUNT_LABEL_PREFIX + str(craft_data.craft_amount)
			craft_time_stat.text = CRAFT_TIME_LABEL_PREFIX + str(craft_data.craft_time)
			
		Global.ITEM_TYPES.TURRET:
			show_stat_labels([craft_time_stat, dps_stat, ability_stat])
			amount_stat.text = AMOUNT_LABEL_PREFIX + str(craft_data.craft_amount)
			craft_time_stat.text = CRAFT_TIME_LABEL_PREFIX + str(craft_data.craft_time)
			var turret_data : TurretData = DataRegistry.turrets[craft_data.crafted_item.key]
			dps_stat.text = DPS_LABEL_PREFIX + str(
				HelperFunctions.return_amount_shorthand(turret_data.get_damage_per_second())
				)
			ability_stat.text = ABILITY_LABEL_PREFIX + turret_data.ability
			
		Global.ITEM_TYPES.MODULE:
			show_stat_labels([craft_time_stat])
			pass
	
	description.text = craft_data.description
	
	for cell in get_tree().get_nodes_in_group(GROUP_REQUIREMENT_CELLS):
		cell.remove_from_group(GROUP_REQUIREMENT_CELLS)
		cell.queue_free()
	
	# gets a sorted list of all requirments sorted from t1 - t5 then alphabetacally
	var sorted_requirements = craft_data.requirements.duplicate()
	sorted_requirements.sort_custom(func(a, b):
		if a == null or b == null or a.item == null or b.item == null:
			return false
		if a.item.tier != b.item.tier:
			return a.item.tier < b.item.tier
		return a.item.key.nocasecmp_to(b.item.key) < 0
	)
	
	for requirment in sorted_requirements:
		if requirment == null or not HelperFunctions.is_valid_item(requirment.item):
			continue
		
		var new_requirment : RecipeRequirement = recipe_requirments_scene.instantiate()
		new_requirment.item_data = requirment.item
		new_requirment.amount_required = requirment.amount
		new_requirment.check_requirement(craft_mult)
		requirments_hflow.add_child(new_requirment)
		new_requirment.add_to_group(GROUP_REQUIREMENT_CELLS)
	
	can_craft_current = can_craft
	
	craft_overlay.visible = not can_craft
	craft_button.disabled = not can_craft
	
	# pining color updating
	if craft_data in Global.pined_crafts.keys():
		craft_pin_texture.modulate = RECIPE_PIN_PINED_COLOR
	else:
		craft_pin_texture.modulate = RECIPE_PIN_NORMAL_COLOR
	
	update_crafting_display()


# Hides all stat labels then shows only the ones passed
func show_stat_labels(labels : Array[Label]) -> void:
	craft_time_stat.visible = false
	amount_stat.visible = false
	dps_stat.visible = false
	ability_stat.visible = false
	
	for label in labels:
		label.visible = true


func _on_one_times_pressed() -> void:
	_change_mult_to(one_times)


func _on_five_times_pressed() -> void:
	_change_mult_to(five_times)


func _on_twentyfive_times_pressed() -> void:
	_change_mult_to(twentyfive_times)


func _on_max_pressed() -> void:
	_change_mult_to(max_times)


func _change_mult_to(button : Button) -> void:
	max_mult = 0
	current_mult_pressed.button_pressed = false
	current_mult_pressed = button
	current_mult_pressed.button_pressed = true
	craft_mult = button_mults[button]
	
	update_crafting_display()


# Tab Controlling ============================================================
func _change_to_tab(new_tab : TABS) -> void:
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


# Recpie Pinning ===========================================================
func _on_pin_recpie_pressed() -> void:
	if current_displayed_requirments:
		recpie_pinning.pin_recipe(current_displayed_requirments)
	
	if current_displayed_requirments in Global.pined_crafts.keys():
		craft_pin_texture.modulate = RECIPE_PIN_PINED_COLOR
	else:
		craft_pin_texture.modulate = RECIPE_PIN_NORMAL_COLOR
