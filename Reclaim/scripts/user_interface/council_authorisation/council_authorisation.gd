class_name CouncilAuthorisation
extends UserInterfaceMenu

const SHOW_POS := Vector2(0, 0)
const HIDE_POS := Vector2(0, -720)

const GROUP_AUTH_REQUIREMENT_CELLS := &"auth_requirment_cells"
const GROUP_AUTH_SELECTION_CELLS := &"authorisation_selection_cells"

# Authorisation changes text
const LEVEL_CANGE_TEXT := "Level : %s -> %s"
const TURRET_TEXT := "Turrets : %s"
const SECTORS_TEXT := "Sectors : %s"
const MODULES_TEXT := "Modules : %s"
const WEAPONS_TEXT := "Weapons : %s"
const RECIPIES_TEXT := "Recipes : %s"
const AUTHORISATIONS_TEXT := "Authorisations : %s"
const ADD_CHANGE_FORMAT := ", "
const MAX_LEVEL_TEXT := "Level : MAX"
const NO_LEVEL_DATA_TEXT := "Invalid Config"
const NO_UNLOCKS_TEXT := "No additional unlocks"
const CUBITS_TEXT := "Cubits: %s"
const NA_LEVEL_TEXT := "Level : "
const NA_DETAILS_TEXT := "Details"


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
	_clear_authorisation_details()
	var authorisation_keys := DataRegistry.authorisation.keys()
	authorisation_keys.sort()
	
	for authorisation_key in authorisation_keys:
		var authorisation_data := DataRegistry.authorisation[authorisation_key] as AuthorisationData
		if not _has_configured_levels(authorisation_data):
			continue
		
		var new_selection_cell : AuthorisationSelection = authorisation_selection_cell.instantiate()
		new_selection_cell.authorisation_data = authorisation_data
		new_selection_cell.council_authorisation = self
		new_selection_cell.add_to_group(GROUP_AUTH_SELECTION_CELLS)
		selection_vbox.add_child(new_selection_cell)
	
		if current_displayed_authorisation == null:
			current_displayed_authorisation = authorisation_data
	
	if current_displayed_authorisation:
		call_deferred("show_authorisation_details", current_displayed_authorisation)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(UserInterfaceMenu.CLOSE_UI_INPUT):
		close_ui()


# Opening and Closing Control ------------------------------------------------
func open_ui() -> void:
	if move_tween_playing:
		return
	
	_set_open_or_close(true)
	if current_displayed_authorisation:
		show_authorisation_details(current_displayed_authorisation)


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
	if authorisation_data == null or authorisation_data.key.is_empty():
		_clear_authorisation_details()
		return

	current_displayed_authorisation = authorisation_data
	authorisation_name.text = HelperFunctions.get_display_name(authorisation_data.key)
	authorisation_icon.texture = authorisation_data.get_icon()
	var authority_level := int(Global.council_authorisations.get(authorisation_data.key, 1))
	Global.council_authorisations[authorisation_data.key] = authority_level
	_clear_requirement_cells()

	if authority_level >= authorisation_data.max_level:
		level_change_label.text = MAX_LEVEL_TEXT
		unlock_change_label.text = NO_UNLOCKS_TEXT
		description_box.text = authorisation_data.description
		_set_authorise_state(false)
		return
	
	
	var sector_unlocks : Array[String]
	var turret_unlocks : Array[String]
	var module_unlocks : Array[String]
	var resource_unlocks : Array[String]
	var authorisation_unlocks : Array[String]
	
	# gets all the unlocks this level of the authorisation gives
	current_displayed_level = authority_level - 1
	var auth_level_details := _get_next_level_details(authorisation_data)
	if not auth_level_details:
		level_change_label.text = NO_LEVEL_DATA_TEXT
		unlock_change_label.text = ""
		description_box.text = authorisation_data.description
		_set_authorise_state(false)
		return
	
	level_change_label.text = LEVEL_CANGE_TEXT % [authority_level, authority_level + 1]
	
	var level_unlocks = auth_level_details.unlocks
	
	for unlock : UnlockTemplate in level_unlocks:
		if unlock == null or unlock.unlock_data == null:
			continue
		
		match unlock.unlock_type:
			UnlockTemplate.UnlockType.SECTOR:
				var sector_key := str(unlock.unlock_data.get("key"))
				if not sector_key.is_empty():
					sector_unlocks.append(HelperFunctions.get_display_name(sector_key))
			
			UnlockTemplate.UnlockType.AUTHORISATION:
				var authorisation_key := str(unlock.unlock_data.get("key"))
				if not authorisation_key.is_empty():
					authorisation_unlocks.append(
						HelperFunctions.get_display_name(authorisation_key)
						)
			
			UnlockTemplate.UnlockType.RECIPE:
				var craft_data = unlock.unlock_data as CraftData
				if craft_data == null or craft_data.crafted_item == null:
					continue
				
				match craft_data.crafted_item.type:
					Global.ItemType.TURRET:
						turret_unlocks.append(HelperFunctions.get_display_name(craft_data.key))
					
					Global.ItemType.MODULE:
						module_unlocks.append(HelperFunctions.get_display_name(craft_data.key))
					
					Global.ItemType.RESOURCES:
						resource_unlocks.append(HelperFunctions.get_display_name(craft_data.key))
					
					Global.ItemType.BASE:
						resource_unlocks.append(HelperFunctions.get_display_name(craft_data.key))
	
	var unlock_change_output : Array[String]
	
	_append_unlock_text(sector_unlocks, SECTORS_TEXT, unlock_change_output)
	_append_unlock_text(turret_unlocks, TURRET_TEXT, unlock_change_output)
	_append_unlock_text(module_unlocks, MODULES_TEXT, unlock_change_output)
	_append_unlock_text(resource_unlocks, RECIPIES_TEXT, unlock_change_output)
	_append_unlock_text(authorisation_unlocks, AUTHORISATIONS_TEXT, unlock_change_output)
	
	if auth_level_details.cubits > 0:
		unlock_change_output.append(
			CUBITS_TEXT % HelperFunctions.comma_number(auth_level_details.cubits)
			)
	
	unlock_change_label.text = ("\n".join(
		unlock_change_output) 
		if not unlock_change_output.is_empty() else 
		NO_UNLOCKS_TEXT
		)
	
	description_box.text = authorisation_data.description
	
	# gets a sorted list of all requirments sorted from t1 - t5 then alphabetacally
	var auth_requirments := auth_level_details.requirments
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
	if current_displayed_authorisation == null:
		_set_authorise_state(false)
		return
	
	var auth_level_details := _get_next_level_details(current_displayed_authorisation)
	can_auth_current = _can_authorise(auth_level_details)
	
	for cell : RecipeRequirement in get_tree().get_nodes_in_group(GROUP_AUTH_REQUIREMENT_CELLS):
		if not cell.check_requirement():
			can_auth_current = false
	
	_set_authorise_state(can_auth_current)


func authorise() -> void:
	var auth_level_details := _get_next_level_details(current_displayed_authorisation)
	if not _can_authorise(auth_level_details) or current_displayed_authorisation == null:
		_check_can_auth()
		return
	
	# Check every requirement immediately before charging resources. This keeps the
	# transaction correct even if storage changed after the UI was last refreshed.
	for requirement : RequirementsTemplate in auth_level_details.requirments:
		if not HelperFunctions.remove_item_from_storage(requirement.item, requirement.amount):
			_check_can_auth()
			return
	
	if auth_level_details.cubits > 0:
		Global.cubits -= auth_level_details.cubits
	
	var key := current_displayed_authorisation.key
	Global.council_authorisations[key] = int(Global.council_authorisations.get(key, 1)) + 1
	Global.save_game()
	
	_refresh_selection_cells()
	show_authorisation_details(current_displayed_authorisation)


func _on_authorise_button_pressed() -> void:
	authorise()


func _can_authorise(auth_level_details: AuthorisationLevel) -> bool:
	if auth_level_details == null:
		return false
	
	if auth_level_details.cubits > Global.cubits:
		return false
	
	for requirement : RequirementsTemplate in auth_level_details.requirments:
		if (
			requirement == null
			or not HelperFunctions.is_valid_item(requirement.item)
			or requirement.amount <= 0
			or not HelperFunctions.has_item_amount(requirement.item, requirement.amount)
		):
			return false
	
	return true


func _get_next_level_details(authorisation_data: AuthorisationData) -> AuthorisationLevel:
	if authorisation_data == null or authorisation_data.key.is_empty():
		return null
	
	var current_level := int(Global.council_authorisations.get(authorisation_data.key, 1))
	if current_level >= authorisation_data.max_level:
		return null
	
	return authorisation_data.levels.get(current_level - 1) as AuthorisationLevel


func _has_configured_levels(authorisation_data: AuthorisationData) -> bool:
	if authorisation_data == null or authorisation_data.key.is_empty():
		return false
	
	for level in authorisation_data.levels:
		if level is AuthorisationLevel:
			return true
	return false


func _clear_requirement_cells() -> void:
	for cell in get_tree().get_nodes_in_group(GROUP_AUTH_REQUIREMENT_CELLS):
		cell.remove_from_group(GROUP_AUTH_REQUIREMENT_CELLS)
		cell.queue_free()


func _clear_authorisation_details() -> void:
	current_displayed_authorisation = null
	_clear_requirement_cells()
	authorisation_name.text = NA_DETAILS_TEXT
	level_change_label.text = NA_LEVEL_TEXT
	unlock_change_label.text = ""
	description_box.text = ""
	authorisation_icon.texture = null
	_set_authorise_state(false)


func _set_authorise_state(can_authorise: bool) -> void:
	can_auth_current = can_authorise
	authorise_overlay.visible = not can_authorise
	authorise_button.disabled = not can_authorise


func _refresh_selection_cells() -> void:
	for selection_cell : AuthorisationSelection in get_tree().get_nodes_in_group(
		GROUP_AUTH_SELECTION_CELLS
		):
		selection_cell.refresh_level_display()
