class_name UserInterfaceMenu
extends Node

const UI_MENU_OPEN_TIMESCALE := 0.3
const PROP_POSITION := "position"

@export var is_storage := false

var move_tween_playing := false


func _enter_tree() -> void:
	if not is_storage:
		process_mode = Node.PROCESS_MODE_ALWAYS


func set_open_timescale(toggle : bool) -> void:
	if not toggle:
		Global.set_time_scale()
	else:
		Global.set_time_scale(UI_MENU_OPEN_TIMESCALE)


## Base tween settings for all UI menus
func hide_or_show_tween(
	target : Node, 
	duration : float, 
	target_pos : Vector2, 
	is_show : bool
) -> void:
	move_tween_playing = true
	
	if is_show:
		target.visible = true
	
	var move_tween = create_tween()
	move_tween.set_ignore_time_scale(true)
	move_tween.set_ease(Tween.EASE_OUT)
	move_tween.set_trans(Tween.TRANS_CUBIC)
	move_tween.tween_property(target, PROP_POSITION, target_pos, duration)
	
	await move_tween.finished
	
	if not is_show:
		target.visible = false
	
	move_tween_playing = false
	
