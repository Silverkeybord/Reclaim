class_name DropData 
extends Resource


@export var key : String

## path to the material 
@export var material_path : String
## size of the side of the cube collision shape
@export var size : Vector3 = Vector3(0.4, 0.4, 0.4)
## the rarity from 1 - 5
@export_range(1, 5) var rarity : int = 1

## the cubits gained when you sell
@export var value : int = 1
## the weight of each resourse for extraction and deploying
@export var weight : int = 1
