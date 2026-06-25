extends CanvasLayer

@export var tooltip_offset := Vector2(0, 0)

@export var name_label : Label
@export var value_label : Label
@export var weight_label : Label
@export var amount_label : Label

@export var texture_rect : TextureRect


func show_itemtip(item : ItemData, amount : int) -> void:
	name_label.text = Global.get_display_name(item.key)
	value_label.text = "Value: " + str(item.value)
	weight_label.text = "Weight: " + str(item.weight)
	amount_label.text = "Amount: " + Global.comma_number(amount) + "x"
	
	visible = true


func hide_itemtip() -> void:
	visible = false


func _process(_delta : float) -> void:
	texture_rect.position = get_viewport().get_mouse_position() + tooltip_offset
