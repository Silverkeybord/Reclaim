class_name AuthorisationSelection
extends ExpandButtons

const NAME_FORMATTING := "-- %s --"

@export var authorisation_data : AuthorisationData
@export var council_authorisation : CouncilAuthorisation

@export var level_cell_scene : PackedScene

@export_group("In Scene Nodes")
@export var authorisation_name_lable : Label
@export var level_icon_hbox : HBoxContainer
@export var authorisation_icon_texture_rect : TextureRect

var level_cells : Array[Panel]


func _ready() -> void:
	if authorisation_data == null or level_cell_scene == null:
		disabled = true
		return

	var display_name = HelperFunctions.get_display_name(authorisation_data.key)
	if authorisation_name_lable:
		authorisation_name_lable.text = NAME_FORMATTING % display_name
	if authorisation_icon_texture_rect:
		authorisation_icon_texture_rect.texture = authorisation_data.get_icon()
	
	for level_index in range(authorisation_data.max_level):
		var new_level_cell = level_cell_scene.instantiate()
		new_level_cell.number = level_index + 1
		level_cells.append(new_level_cell)
		level_icon_hbox.add_child(new_level_cell)

	refresh_level_display()


func refresh_level_display() -> void:
	if authorisation_data == null:
		return

	var current_level := int(Global.council_authorisations.get(authorisation_data.key, 1))
	for level_cell in level_cells:
		level_cell.set_achieved(level_cell.number <= current_level)


func _on_pressed() -> void:
	if authorisation_data == null or council_authorisation == null:
		return

	play_press_sound()
	council_authorisation.show_authorisation_details(authorisation_data)
