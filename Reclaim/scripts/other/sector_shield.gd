extends Node3D


@export var shield_health : float = 100
@export var max_shield_health : float = 100


func _on_shield_area_body_entered(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group("player"):
		body.pick_up_area.monitoring = false
		body.in_shield = true


func _on_shield_area_body_exited(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group("player"):
		body.pick_up_area.monitoring = true
		body.in_shield = false
