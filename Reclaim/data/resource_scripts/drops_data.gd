class_name DropData 
extends Resource


@export var key : String

## path to the material 
@export var material_path : String = "res://textures_and_materials/drops/none.tres"
## the path of the item texture
@export var item_texture : String = "res://2d_assets/items/t1/none.png"
## size of the side of the cube collision shape
@export var size : Vector3 = Vector3(0.4, 0.4, 0.4)
## the rarity from 1 - 5
@export_range(1, 5) var rarity : int = 1

## the cubits gained when you sell
@export var value : int = 1
## the weight of each resourse for extraction and deploying
@export var weight : int = 1

## the mesh of the drop if its set else its just a cube with the size pramaters
@export var mesh : Mesh
