class_name ExpandButtons
extends Button

# You need to turn on offset transformations for this to work

const PRESS_SOUND : SoundInfo = preload("res://sounds/user_interface/button_click_soundinfo.tres")

const TWEEN_TIME := 0.05
const NORMAL_SCALE := Vector2(1, 1)
const SCALE_PROPERTY := "offset_transform_scale"

@export var expand_toggle : bool = true
@export var scale_target := 1.05

@onready var hover_scale := Vector2(scale_target, scale_target)


func _on_mouse_entered() -> void:
	if expand_toggle:
		var scale_tween = create_tween()
		scale_tween.set_ease(Tween.EASE_OUT)
		scale_tween.tween_property(self, SCALE_PROPERTY, hover_scale, TWEEN_TIME)
	
	toggle_highlight(true)


func _on_mouse_exited() -> void:
	if expand_toggle:
		var scale_tween = create_tween()
		scale_tween.set_ease(Tween.EASE_OUT)
		scale_tween.tween_property(self, SCALE_PROPERTY, NORMAL_SCALE, TWEEN_TIME)
	
	toggle_highlight(false)


func toggle_highlight(_show_highlight := false) -> void:
	pass


func _on_pressed() -> void:
	play_press_sound()


func play_press_sound() -> void:
	HelperFunctions.spawn_temp_sound(PRESS_SOUND)
