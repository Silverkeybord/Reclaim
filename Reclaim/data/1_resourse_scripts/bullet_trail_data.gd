class_name bullet_trail_data
extends Resource

enum SHAPES {
	SQUARE,
	CLYINDER,
}

@export var key: String
## shape of the bullet trail
@export var shape : SHAPES
## diameter of the trail
@export var size : float = 0.2
## time before queuefree'ing
@export var life : float = 0.2
## if it fades out or not
@export var fade : bool = false
