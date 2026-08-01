class_name ExtractionCell
extends BaseStorageCell

const LEFT_CLICK := "m1"
const RIGHT_CLICK := "m2"
const SHIFT_TOGGLE := "shift"

const MOVE_ONE := 1
const MOVE_FIVE := 5
const MOVE_TWENTY_FIVE := 25
const MOVE_MAX := 0

@export var extraction_ui : CanvasLayer
@export var in_storage : bool = true


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(LEFT_CLICK):
		
		if Input.is_action_pressed(SHIFT_TOGGLE):
			_move_to_other(MOVE_TWENTY_FIVE)
		else:
			_move_to_other(MOVE_ONE)
	
	elif Input.is_action_just_pressed(RIGHT_CLICK):
		if Input.is_action_pressed(SHIFT_TOGGLE):
			_move_to_other(MOVE_MAX)
		else:
			_move_to_other(MOVE_FIVE)


func update_amount() -> void:
	if not HelperFunctions.is_valid_item(item_resource):
		amount = DEFAULT_AMOUNT
		visible = false
		return
	
	if in_storage:
		amount = HelperFunctions.get_item_amount(item_resource)
	else:
		amount = HelperFunctions.get_item_amount(item_resource, Global.extraction_storage)
	
	amount_label.text = HelperFunctions.return_amount_shorthand(amount)
	
	visible = amount > 0


func _move_to_other(move_amount : int) -> void:
	extraction_ui.move_item(in_storage, move_amount, item_resource)


func toggle_mouse_detection(toggle : bool) -> void:
	set_process(toggle)
