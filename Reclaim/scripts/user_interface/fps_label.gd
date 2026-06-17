extends Label

const FPS_TEXT := "FPS: "

const WHITE_FPS := Color(1.0, 1.0, 1.0, 1.0)
const YELLOW_FPS := Color(1.0, 1.0, 0.451, 1.0)
const ORANGE_FPS := Color(1.0, 0.647, 0.0, 1.0)
const RED_FPS := Color(1.0, 0.49, 0.451)

const WHITE_THRESHOLD := 50
const YELLOW_THRESHOLD := 40
const ORANGE_THRESHOLD := 20
const RED_THRESHOLD := 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var FPS = round(1/delta * 10) / 10
	if FPS > WHITE_THRESHOLD:
		modulate = WHITE_FPS
	elif FPS > YELLOW_THRESHOLD:
		modulate = YELLOW_FPS
	elif FPS > ORANGE_THRESHOLD:
		modulate = ORANGE_FPS
	elif FPS > RED_THRESHOLD:
		modulate = RED_FPS
	
	text = FPS_TEXT + str(FPS)
