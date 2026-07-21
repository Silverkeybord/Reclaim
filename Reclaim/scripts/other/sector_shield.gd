class_name SectorShield
extends Node3D

const PLAYER_GROUP_NAME := "player"
const ENEMY_METADATA_KEY := "enemy"

@export var run_ui : Control

@export var shield_health : float = 100
@export var max_shield_health : float = 100

@export var heal_interval : float = 2.5
@export var heal_amount : float = 5
@export var heal_timer : Timer


func _ready() -> void:
	heal_timer.wait_time = heal_interval


func hit_shield(damage : float) -> void:
	if shield_health - damage < 0:
		shield_health = 0
	else:
		shield_health -= damage
	
	if heal_timer.is_stopped():
		heal_timer.start()
	
	run_ui.update_visuals(damage)


func heal_shield(heal : float) -> void:
	if shield_health == max_shield_health:
		return
	
	if shield_health + heal > max_shield_health:
		shield_health = max_shield_health
	else:
		heal_timer.start()
		shield_health += heal
	
	run_ui.update_visuals(heal, false)


func _on_shield_area_body_entered(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group(PLAYER_GROUP_NAME):
		body.pick_up_area.monitoring = false
		body.in_shield = true
	
	elif body.has_meta(ENEMY_METADATA_KEY):
		body.can_attack = true
		body.start_attacking()


func _on_shield_area_body_exited(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group(PLAYER_GROUP_NAME):
		body.pick_up_area.monitoring = true
		body.in_shield = false
		
	elif body.has_meta(ENEMY_METADATA_KEY):
		body.can_attack = false
		body.stop_attacking()


func _on_heal_timer_timeout() -> void:
	heal_timer.wait_time = heal_interval
	heal_shield(heal_amount)
