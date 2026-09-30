class_name CouncilAuthorisation
extends UserInterfaceMenu

const SHOW_POS := Vector2(0, 0)
const HIDE_POS := Vector2(0, -720)

const GROUP_AUTH_REQUIREMENT_CELLS := &"auth_requirment_cells"

# Authorisation changes text
const LEVEL_CANGE_TEXT := "Level : %s -> %s"
const TURRET_TEXT := "Turrets : %s"
const SECTORS_TEXT := "Sectors : %s"
const MODULES_TEXT := "Modules : %s"
const WEAPONS_TEXT := "Weapons : %s"
const RECIPIES_TEXT := "Recpies : %s"
const ADD_CHANGE_FORMAT := ", "

@export var ui_root : Control
@export var selection_vbox : VBoxContainer

@export_group("Authorisation Details")
@export var requirments_hflow : HFlowContainer
@export var level_change_label : Label
@export var unlock_change_label : Label
@export var authorisation_name : Label
@export var description_box : RichTextLabel
@export var authorise_button : Button
@export var authorisation_icon : TextureRect
@export var authorise_overlay : PanelContainer

@export_group("Other Scenes")
@export var authorisation_selection_cell : PackedScene
@export var recipe_requirments_scene : PackedScene

var current_displayed_authorisation : AuthorisationData
var current_displayed_level : int
var can_auth_current : bool = false


func _ready() -> void:
	set_process(false)
	for authorisation in DataRegistry.authorisation:
		var new_selection_cell : AuthorisationSelection = authorisation_selection_cell.instantiate()
		new_selection_cell.authorisation_data = DataRegistry.authorisation[authorisation]
		new_selection_cell.council_authorisation = self
		selection_vbox.add_child(new_selection_cell)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(UserInterfaceMenu.CLOSE_UI_INPUT):
		close_ui()


# Opening and Closing Control ------------------------------------------------
func open_ui() -> void:
	if move_tween_playing:
		return
	
	_set_open_or_close(true)


func close_ui() -> void:
	if move_tween_playing:
		return
	
	_set_open_or_close(false)


func _set_open_or_close(toggle : bool) -> void:
	hide_or_show_tween(
		ui_root,
		SHOW_POS if toggle else HIDE_POS,
		toggle
		)
	
	
	Global.ui_open = toggle
	Global.authorization_open = toggle
	set_open_timescale(toggle)
	set_process(toggle)
	HelperFunctions.set_mouse_captured(true, not toggle)


# Displaying details ands requirments for the authorisation -------------------
func show_authorisation_details(authorisation_data : AuthorisationData) -> void:
	current_displayed_authorisation = authorisation_data
	authorisation_name.text = HelperFunctions.get_display_name(authorisation_data.key)
	authorisation_icon.texture = authorisation_data.get_icon()
	var authority_level = Global.council_authorisations[authorisation_data.key]
	level_change_label.text = LEVEL_CANGE_TEXT % [authority_level, authority_level + 1]
	
	
	var sector_unlocks : Array[String]
	var turret_unlocks : Array[String]
	var module_unlocks : Array[String]
	#var weapon_unlocks : Array[String]
	var resource_unlocks : Array[String]
	var authorisation_unlocks : Array[String]
	
	# gets all the unlocks this level of the autorisation 	 gets
	current_displayed_level = Global.council_authorisations.get(authorisation_data.key) - 1
	var auth_level_details = authorisation_data.levels.get(current_displayed_level)
	if not auth_level_details:
		return
	
	var level_unlocks = auth_level_details.unlocks
	
	for unlock : UnlockTemplate in level_unlocks:
		match unlock.unlock_type:
			UnlockTemplate.UnlockType.SECTOR:
				var display_name := HelperFunctions.get_display_name(unlock.unlock_data.key)
				sector_unlocks.append(display_name)
			
			UnlockTemplate.UnlockType.AUTHORISATION:
				var display_name := HelperFunctions.get_display_name(unlock.unlock_data.key)
				authorisation_unlocks.append(display_name)
			
			UnlockTemplate.UnlockType.RECIPE:
				var craft_data = unlock.unlock_data as CraftData
				
				match craft_data.crafted_item.type:
					Global.ItemType.TURRET:
						turret_unlocks.append(HelperFunctions.get_display_name(craft_data.key))
					
					Global.ItemType.BASE:
						module_unlocks.append(HelperFunctions.get_display_name(craft_data.key))
					
					Global.ItemType.RESOURCES:
						resource_unlocks.append(HelperFunctions.get_display_name(craft_data.key))
	
	var unlock_change_output : Array[String]
	
	_append_unlock_text(sector_unlocks, SECTORS_TEXT, unlock_change_output)
	_append_unlock_text(turret_unlocks, TURRET_TEXT, unlock_change_output)
	_append_unlock_text(module_unlocks, MODULES_TEXT, unlock_change_output)
	_append_unlock_text(resource_unlocks, SECTORS_TEXT, unlock_change_output)
	_append_unlock_text(authorisation_unlocks, SECTORS_TEXT, unlock_change_output)
	
	unlock_change_label.text = "\n".join(unlock_change_output)
	
	description_box.text = authorisation_data.description
	
	for cell in get_tree().get_nodes_in_group(GROUP_AUTH_REQUIREMENT_CELLS):
		cell.remove_from_group(GROUP_AUTH_REQUIREMENT_CELLS)
		cell.queue_free()
	
	# gets a sorted list of all requirments sorted from t1 - t5 then alphabetacally
	var auth_requirments := authorisation_data.levels[current_displayed_level].requirments
	var sorted_requirements = auth_requirments.duplicate()
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
		requirments_hflow.add_child(new_requirment)
		new_requirment.add_to_group(GROUP_AUTH_REQUIREMENT_CELLS)
	
	_check_can_auth()


func _append_unlock_text(unlock_list: Array, format_text: String, output_array: Array) -> void:
	if not unlock_list.is_empty():
		var whole_string := ADD_CHANGE_FORMAT.join(unlock_list)
		output_array.append(format_text % whole_string)


# gets everying to check their display and values 
func _check_can_auth() -> void:
	if not Global.authorization_open:
		return
	
	# gets all the cells to check if there is enough and highlights craft button
	can_auth_current = true
	
	var cells := get_tree().get_nodes_in_group(GROUP_AUTH_REQUIREMENT_CELLS)
	for cell : RecipeRequirement in cells:
		if not cell.check_requirement():
			authorise_overlay.visible = true
			can_auth_current = false
	
	authorise_overlay.visible = not can_auth_current
	authorise_button.disabled = not can_auth_current
	
	if not current_displayed_authorisation:
		authorise_overlay.visible = true
	
	for cell : RecipeRequirement in get_tree().get_nodes_in_group(GROUP_AUTH_REQUIREMENT_CELLS): 
		cell.check_requirement()
