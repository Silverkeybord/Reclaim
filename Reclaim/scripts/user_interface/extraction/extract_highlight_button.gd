extends ExpandButtons

const PRESS_DEBOUNCE := 0.1

@export var highlight : Panel


func toggle_highlight(show_highlight := false) -> void:
	highlight.visible = show_highlight


func _on_pressed() -> void:
	play_press_sound()
	highlight.visible = false
	var debounce_timer = Timer.new()
	debounce_timer.wait_time = PRESS_DEBOUNCE
	HelperFunctions.add_to_root_node(debounce_timer)
	debounce_timer.start()
	await debounce_timer.timeout
	highlight.visible = true
