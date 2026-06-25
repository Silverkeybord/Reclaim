class_name CraftData
extends Resource


@export var key : String

@export_range(1, 8) var required_ship_tier : int = 1
## a list of requirments derived from "RequirementsTemplate"
@export var requirements : Array[RequirementsTemplate]
## the resulting item crafted
@export var crafted_item : ItemData
## the resulting amout of the crafted item gained when crafted
@export var craft_amount : int = 1
## the texture on the crafting cell
@export var texture : Texture
## a description of what you are crafting
@export var description : String = "
This is an item in a game you can craft from the game called reclaim made by a
final year high school student.
"
## time taken to craft the item
@export var craft_time : float = 0.05
