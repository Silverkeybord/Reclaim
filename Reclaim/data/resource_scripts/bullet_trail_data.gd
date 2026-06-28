class_name BulletTrailData
extends Resource

enum SHAPES {
	SQUARE,
	CLYINDER,
}

@export var key: String

@export_group("Properties")
## shape of the bullet trail
@export var shape : SHAPES
## diameter of the trail
@export var size : float = 0.2
## time before queuefree'ing
@export var life : float = 0.2
## the material of the bulet trail
@export var material : Material

@export_group("Animations and Effects")
## if it fades out or not
@export var fade : bool = false
## if it will expand before queue free'ing
@export var expand : bool = false
## the size the trail will expand to when expanding
@export var expand_size : float = 0.2
