extends Node3D


func _ready() -> void:
	_check_turret_slots()


func _check_turret_slots() -> void:
	var turrets_level_nodes = get_children()
	var slot_level = Global.turret_slots
	
	for turret_level_node in turrets_level_nodes:
		if slot_level == 0:
			break
		
		turret_level_node.visible = true
		
		var turret_slots = turret_level_node.get_children()
		for turret_slot in turret_slots:
			turret_slot.unlocked = true
		slot_level -= 1
