class_name ExtractionCell
extends BaseStorageCell

const LEFT_CLICK := "m1"
const RIGHT_CLICK := "m2"
const SHIFT_TOGGLE := "shift"

const MOVE_ONE := 1
const MOVE_FIVE := 5
const MOVE_MAX := -1

@export var extraction_ui : CanvasLayer
@export var in_storage : bool = true


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(LEFT_CLICK):
		
		if Input.is_action_pressed(SHIFT_TOGGLE):
			_move_to_other(MOVE_MAX)
		else:
			_move_to_other(MOVE_ONE)
	
	elif Input.is_action_just_pressed(RIGHT_CLICK):
		_move_to_other(MOVE_FIVE)


func _move_to_other(move_amount : int) -> void:
	if move_amount == MOVE_MAX:
		pass


func toggle_mouse_detection(toggle : bool) -> void:
	set_process(toggle)
