extends CanvasLayer

const INPUT_PAUSE: StringName = &"pause"

const MAX_SENSITIVITY_MULT := 5.0
const MIN_SENSITIVITY_MULT := 0.2
const DELETE_CONFIRM_PRESS := 4

const DELETE_PRESSES_TEXT := {
	0: "Delete Save",
	1: "Are you sure?",
	2: "Really sure?",
	3: "Last check",
	4: "OK BYE :o"
}

@export var sensitivity_slider: HSlider
@export var sensitivity_line_edit: LineEdit
@export var action_bars_texture_rect: TextureRect
@export var fps_texture_rect: TextureRect
@export var delete_timer: Timer
@export var delete_lable: Label

@export_group("Textures")
@export var untoggled_texture: Texture
@export var toggled_texture: Texture

@onready var toggled_lookup_textures := {
	false: untoggled_texture,
	true: toggled_texture
}

var consecutive_presses: int = 0
var last_mouse_captured_mode: bool


func _ready() -> void:
	if sensitivity_slider:
		sensitivity_slider.min_value = MIN_SENSITIVITY_MULT
		sensitivity_slider.max_value = MAX_SENSITIVITY_MULT
		sensitivity_slider.value = Global.sensitivity
	if sensitivity_line_edit:
		sensitivity_line_edit.text = str(Global.sensitivity)
	_refresh_toggle_textures()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(INPUT_PAUSE) and not Global.ui_open:
		_toggle_pause()
	_check_sensitivity_slider()


func _toggle_pause() -> void:
	var toggle: bool = not Global.paused
	if toggle:
		last_mouse_captured_mode = Global.mouse_captured
		HelperFunctions.set_mouse_captured(true, not toggle)
	else:
		HelperFunctions.set_mouse_captured(true, last_mouse_captured_mode)
	
	Global.set_paused(toggle)
	visible = toggle


# sensitivity slider logic ----------------------------------------------------
func _on_line_edit_text_submitted(new_text: String) -> void:
	if sensitivity_slider == null or sensitivity_line_edit == null:
		return
	if new_text.is_valid_float() or new_text.is_valid_int():
		Global.sensitivity = clampf(
			float(new_text),
			MIN_SENSITIVITY_MULT,
			MAX_SENSITIVITY_MULT
		)
	sensitivity_slider.value = Global.sensitivity
	sensitivity_line_edit.text = str(Global.sensitivity)


func _check_sensitivity_slider() -> void:
	if sensitivity_slider == null or sensitivity_line_edit == null:
		return
	if Global.sensitivity == sensitivity_slider.value:
		return
	Global.sensitivity = sensitivity_slider.value
	sensitivity_line_edit.text = str(Global.sensitivity)


func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	if sensitivity_slider:
		sensitivity_slider.editable = not toggled_on


func _on_h_slider_drag_started() -> void:
	if sensitivity_line_edit:
		sensitivity_line_edit.editable = false


func _on_h_slider_drag_ended(_value_changed: bool) -> void:
	if sensitivity_line_edit:
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
func _on_toggle_action_bar_pressed() -> void:
	Global.show_action_bar = not Global.show_action_bar
	_refresh_toggle_textures()


func _on_toggle_show_fps_pressed() -> void:
	Global.show_fps = not Global.show_fps
	_refresh_toggle_textures()


func _refresh_toggle_textures() -> void:
	if action_bars_texture_rect:
		action_bars_texture_rect.texture = toggled_lookup_textures[Global.show_action_bar]
	if fps_texture_rect:
		fps_texture_rect.texture = toggled_lookup_textures[Global.show_fps]


# Delete game data ------------------------------------------------------------
func _on_delete_save_pressed() -> void:
	consecutive_presses += 1
	if delete_timer:
		delete_timer.start()
	if delete_lable:
		delete_lable.text = DELETE_PRESSES_TEXT.get(consecutive_presses, "")
	if consecutive_presses == DELETE_CONFIRM_PRESS:
		Global.reset_game()


func _on_delete_timer_timeout() -> void:
	consecutive_presses = 0
	if delete_lable:
		delete_lable.text = DELETE_PRESSES_TEXT.get(consecutive_presses, "")
