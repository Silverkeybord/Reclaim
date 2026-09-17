extends CanvasLayer

const INPUT_PAUSE := "pause"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(INPUT_PAUSE):
		_toggle_pause()


func _toggle_pause() -> void:
	var toggle = not Global.paused
	
	HelperFunctions.set_mouse_captured(true, not toggle)
	Global.set_paused(toggle)
	visible = toggle
