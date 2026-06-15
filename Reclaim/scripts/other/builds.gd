class_name builds
extends Node


@export var build : String 
@export var build_type : Global.BUILD_TYPES


func pick_up() -> void:
	queue_free()
