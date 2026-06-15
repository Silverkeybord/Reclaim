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
		for slot in turret_slots:
			slot.unlocked = true
		slot_level -= 1


func _toggle_build_mode(build_mode) -> void:
	if build_mode:
		visible = true
	else:
		visible = false
