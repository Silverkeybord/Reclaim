class_name ItemPinning
extends Control

const MAX_PINNED := 3

@export var pining_vbox := VBoxContainer

static var pined_crafts : Array[CraftData]
