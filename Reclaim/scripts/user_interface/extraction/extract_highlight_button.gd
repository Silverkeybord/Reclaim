extends ExpandButtons

const PRESS_DEBOUNCE := 0.1

@export var highlight : Panel
@export var highlight_overlay_toggle : bool = true


func toggle_highlight(show_highlight := false) -> void:
	highlight.visible = show_highlight


func _on_pressed() -> void:
	play_press_sound()
	highlight.visible = false
	
	if highlight_overlay_toggle:
		var debounce_timer = Timer.new()
		debounce_timer.wait_time = PRESS_DEBOUNCE
		HelperFunctions.add_to_root_node(debounce_timer)
		debounce_timer.start()
		await debounce_timer.timeout
	
	highlight.visible = true
