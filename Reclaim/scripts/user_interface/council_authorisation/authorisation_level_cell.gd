extends Panel

const PANEL_NAME := "panel"

@export var achieved_style : StyleBoxFlat
@export var number : int 

@export var number_lable: Label


func _ready() -> void:
	number_lable.text = str(number)


func _set_green() -> void:
	add_theme_stylebox_override(PANEL_NAME, achieved_style)
