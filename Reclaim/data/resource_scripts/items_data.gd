class_name ItemData 
extends Resource

const NONE_MAT : String = "res://textures_and_materials/items/none.tres"
const NONE_ITEM : String = "res://2d_assets/items/none.png"

const ITEM_TEXTURE_PATH : String = "res://2d_assets/items/"
const MATERIAL_TEXTURE_PATH : String = "res://textures_and_materials/items/"

const TRES_TYPE : String = ".tres"
const PNG_TYPE : String = ".png"
const SLASH : String = "/"

@export var key : String

## size of the side of the cube collision shape
@export var size : Vector3 = Vector3(0.4, 0.4, 0.4)
## the tier from 1 - 5
@export_range(1, 5) var tier : int = 1
## the type of item somthing is
@export_enum(
	"turret",
	"base",
	"module",
	"resources"
) var type : String = "resourse"


## the cubits gained when you sell
@export var value : float = 1
## the weight of each resourse for extraction and deploying
@export var weight : int = 1

## the mesh of the drop if its set else its just a cube with the size pramaters
@export var mesh : Mesh


func get_material_path() -> String:
	return (
			MATERIAL_TEXTURE_PATH + 
			str(tier) +
			SLASH +
			key + 
			TRES_TYPE
		)


func get_item_path() -> String:
	return (
			ITEM_TEXTURE_PATH + 
			str(tier) +
			SLASH +
			key + 
			PNG_TYPE
		)
