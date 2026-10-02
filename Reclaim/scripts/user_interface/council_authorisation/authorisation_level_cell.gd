extends Panel

const PANEL_NAME := "panel"

@export var achieved_style : StyleBoxFlat
@export var unachieved_style : StyleBoxFlat
@export var number : int 

@export var number_lable: Label


func _ready() -> void:
	if number_lable:
		number_lable.text = str(number)


func set_achieved(achieved: bool) -> void:
	var style := achieved_style if achieved else unachieved_style
	if style:
		add_theme_stylebox_override(PANEL_NAME, style)
