class_name turret_basics

extends Node3D

enum SHOOTING_METHODS {
	FIRST,
	LAST,
	STRONG,
	RANDOM,
}

@export var turret_range_coll : CollisionShape3D
@export var turret_shooting_type := SHOOTING_METHODS.FIRST
@export var bullet_trail_scene : PackedScene
