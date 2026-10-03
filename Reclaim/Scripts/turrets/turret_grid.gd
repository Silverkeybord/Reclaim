extends Node3D

const TURRET_SLOTS_AUTHORISATION: AuthorisationData = preload(
	"res://data/authorisation/turret_slots.tres"
	)
const PROP_UNLOCKED: StringName = &"unlocked"


func _ready() -> void:
	_check_turret_slots()


func _check_turret_slots() -> void:
	var turrets_level_nodes := get_children()
	var slot_level: int = int(
		Global.council_authorisations.get(TURRET_SLOTS_AUTHORISATION.key, 0)
	)
	if slot_level < 0:
		return
	
	for turret_level_node in turrets_level_nodes:
		if slot_level < 0:
			break

		if turret_level_node is not Node3D:
			continue

		turret_level_node.visible = true
		
		var turret_slots := turret_level_node.get_children()
		for slot in turret_slots:
			slot.set(PROP_UNLOCKED, true)
		slot_level -= 1


func _toggle_build_mode(build_mode: bool) -> void:
	if build_mode:
		visible = true
	else:
		visible = false
