class_name ItemData 
extends Resource

const NONE_MAT := preload("res://textures_and_materials/items/none.tres")
const NONE_ITEM := preload("res://2d_assets/items/none.png")

const TRES_TYPE : String = ".tres"
const PNG_TYPE : String = ".png"
const SLASH : String = "/"

@export var key : String

## size of the side of the cube collision shape
@export var size : Vector3 = Vector3(0.4, 0.4, 0.4)
## the tier from 1 - 5
@export_range(1, 5) var tier : int = 1
## the type of item somthing is
@export var type : Global.ITEM_TYPES = Global.ITEM_TYPES.RESOURCES
## the item texture for ui elements
@export var item_texture : Texture2D
## the material of the item in the 3D world
@export var material : Material


## the cubits gained when you sell
@export var value : float = 1
## the weight of each resourse for extraction and deploying
@export var weight : int = 1
## the mesh of the drop if its set else its just a cube with the size pramaters
@export var mesh : Mesh


func get_material() -> Material:
	if material:
		return material
	else:
		return NONE_MAT


func get_item_texture() -> Texture2D:
	if item_texture:
		return item_texture
	else:
		return NONE_ITEM
