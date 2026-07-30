extends ExpandButtons

const PRESS_DEBOUNCE := 0.1

@export var highlight : Panel


func toggle_highlight(show_highlight := false) -> void:
	highlight.visible = show_highlight


func _on_pressed() -> void:
	play_press_sound()
	highlight.visible = false
	await get_tree().create_timer(PRESS_DEBOUNCE).timeout
	highlight.visible = true
