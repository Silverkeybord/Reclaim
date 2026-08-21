extends PanelContainer

const LABEL_FORMAT := "%d/%d"
const GREEN_COLOR := Color("9BFF9B")
const RED_COLOR := Color("ff948bff")

@export var required_amount : int
@export var item : ItemData
@export var amount_label : Label
@export var item_texture : TextureRect


func _ready() -> void:
	set_process(false)
	
	amount_label.text = LABEL_FORMAT % [HelperFunctions.get_item_amount(item), required_amount]
	
	if Global.crafting_pin_open:
		set_process(true)


func _process(_delta: float) -> void:
	amount_label.text = LABEL_FORMAT % [HelperFunctions.get_item_amount(item), required_amount]
