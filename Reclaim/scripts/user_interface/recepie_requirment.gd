extends PanelContainer

const BACKGROUND_FILL : Dictionary = {
	1 : Color(0.541, 0.561, 0.596),
	2 : Color(0.494, 0.937, 0.427),
	3 : Color(0.333, 0.588, 1.0),
	4 : Color(1.0, 0.882, 0.404),
	5 : Color(1.0, 0.318, 0.318)
}


@export var required : int

@export var have_indication : TextureRect
@export var item_image : TextureRect
@export var label : Label
