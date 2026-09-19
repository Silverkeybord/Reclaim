extends PanelContainer

const NAME_FORMATTING := "-- %s --"

@export var authorisation_data : AuthorisationData

@export var level_cell : PackedScene

@export_group("In Scene Nodes")
@export var authorisation_name_lable : Label
@export var level_icon_hbox : HBoxContainer
@export var authorisation_icon_texture_rect : TextureRect


func _ready() -> void:
	var display_name = HelperFunctions.get_display_name(authorisation_data.authorisation)
	authorisation_name_lable.text = NAME_FORMATTING % display_name
	
	for x in range(authorisation_data.max_level):
		var new_level_cell = level_cell.instantiate()
		new_level_cell.number = x + 1
		level_icon_hbox.add_child(new_level_cell)
		
	
