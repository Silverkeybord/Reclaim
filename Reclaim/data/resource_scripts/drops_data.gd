class_name DropData 
extends Resource

const NONE_MAT : String = "res://textures_and_materials/drops/none.tres"
const NONE_ITEM : String = "res://2d_assets/items/none.png"

const ITEM_TEXTURE_PATH : String = "res://2d_assets/items/"
const MATERIAL_TEXTURE_PATH : String = "res://textures_and_materials/drops/"

const TRES_TYPE : String = ".tres"
const PNG_TYPE : String = ".png"
const SLASH : String = "/"

@export var key : String

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
