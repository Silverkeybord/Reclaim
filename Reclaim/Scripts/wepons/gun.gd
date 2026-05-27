class_name basic_wepon

extends Node3D

@export var shooting_type : Global.SHOT_TYPE
@export var bullet_type : String
@export var bullet_spawn : Marker3D
@export var cooldown : float = 1.0

@export var player : CharacterBody3D
