extends Control

const MAX_NOTIF : int = 10
const ITEM_NOTIF_SCENE : PackedScene = preload("res://scenes/user_interface/item_notif.tscn")

@export var notif_vbox : VBoxContainer

var item_notifs : Dictionary
var notif_amount : int = 0


func pick_up_item(item_data : ItemData) -> void:
	if item_data.key in item_notifs:
		item_notifs[item_data.key].item_pick_up()
	else:
		if notif_amount >= MAX_NOTIF:
			return
		
		notif_amount += 1
		var notif = ITEM_NOTIF_SCENE.instantiate()
		item_notifs[item_data.key] = notif
		notif.item_data = item_data
		notif.notif_controller = self
		
		notif_vbox.add_child(notif)


func remove_notif(item_data : ItemData) -> void:
	if not item_data.key in item_notifs:
		return
	
	item_notifs.erase(item_data.key)
	notif_amount -= 1
