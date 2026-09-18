extends CanvasLayer

const INPUT_PAUSE := "pause"

const MAX_SENSITIVITY_MULT := 5.0
const MIN_SENSITIVITY_MULT := 0.2

@export var sensitivity_slider : HSlider
@export var sensitivity_line_edit : LineEdit
@export var input_tips_texture_rect : TextureRect
@export var fps_texture_rect : TextureRect

@export_group("Textures")
@export var untoggled_texture : Texture
@export var toggled_texture : Texture

@onready var toggled_lookup_textures := {
	false : untoggled_texture,
	true : toggled_texture
}


func _ready() -> void:
	sensitivity_slider.min_value = MIN_SENSITIVITY_MULT
	sensitivity_slider.max_value = MAX_SENSITIVITY_MULT
	sensitivity_slider.value = Global.sensitivity
	sensitivity_line_edit.text = str(Global.sensitivity)
	input_tips_texture_rect.texture = toggled_lookup_textures[Global.show_input_tip]
	fps_texture_rect.texture = toggled_lookup_textures[Global.show_fps]


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(INPUT_PAUSE):
		_toggle_pause()
	
	_check_sensitivity_slider()


func _toggle_pause() -> void:
	var toggle = not Global.paused
	
	HelperFunctions.set_mouse_captured(true, not toggle)
	Global.set_paused(toggle)
	visible = toggle


# sensitivity slider logic ----------------------------------------------------
func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float() or new_text.is_valid_int():
		Global.sensitivity = clampf(
			float(new_text),
			MIN_SENSITIVITY_MULT,
			MAX_SENSITIVITY_MULT
		)
	
	sensitivity_line_edit.text = str(Global.sensitivity)


func _check_sensitivity_slider() -> void:
	if Global.sensitivity != sensitivity_slider.value:
		Global.sensitivity = sensitivity_slider.value
		sensitivity_line_edit.text = str(Global.sensitivity)


func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	sensitivity_slider.editable = not toggled_on


func _on_h_slider_drag_started() -> void:
	sensitivity_line_edit.editable = false


func _on_h_slider_drag_ended(_value_changed: bool) -> void:
	sensitivity_line_edit.editable = true


# button options presses ------------------------------------------------------
func _on_continue_button_pressed() -> void:
	_toggle_pause()


func _on_save_button_pressed() -> void:
	Global.save_game()


func _on_exit_button_pressed() -> void:
	await Global.save_game()
	get_tree().quit()


# toggles pressed -------------------------------------------------------------
func _on_toggle_input_tips_pressed() -> void:
	Global.show_input_tip = not Global.show_input_tip
	input_tips_texture_rect.texture = toggled_lookup_textures[Global.show_input_tip]


func _on_toggle_show_fps_pressed() -> void:
	Global.show_fps = not Global.show_fps
	fps_texture_rect.texture = toggled_lookup_textures[Global.show_fps]


func _on_h_slider_mouse_entered() -> void:
	print("wuta;sdhfaniefa")
