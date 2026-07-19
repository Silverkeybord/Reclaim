class_name Bases

extends Builds

@export var slot : turret_slot


func check_for_turret() -> void:
	if slot.turret:
		slot.turret.pick_up()
