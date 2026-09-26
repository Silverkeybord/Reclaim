class_name CouncilAuthorisation
extends UserInterfaceMenu

const SHOW_POS := Vector2(0, 0)
const HIDE_POS := Vector2(0, -720)

# Authorisation changes text
const LEVEL_CANGE_TEXT := "%s -> %s"
const TURRET_TEXT := "Turrets : %s"
const SECTORS_TEXT := "Sectors : %s"
const MODULES_TEXT := "Modules : %s"
const WEAPONS_TEXT := "Weapons : %s"
const RECIPIES_TEXT := "Recpies : %s"

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

@export_group("Other Scenes")
@export var authorisation_selection_cell : PackedScene
@export var recipe_requirments_scene : PackedScene

var current_displayed_authorisation : AuthorisationData


func _ready() -> void:
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
	Global.crafting_open = toggle
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
