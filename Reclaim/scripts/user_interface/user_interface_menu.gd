class_name UserInterfaceMenu
extends Node

const UI_MENU_OPEN_TIMESCALE := 0.3

@export var is_storage := false


func _enter_tree() -> void:
	if not is_storage:
		process_mode = Node.PROCESS_MODE_ALWAYS


func set_open_timescale(toggle : bool) -> void:
	if not toggle:
		Global.set_time_scale()
	else:
		Global.set_time_scale(UI_MENU_OPEN_TIMESCALE)
	
