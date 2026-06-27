extends StaticBody3D

@export var crafting_ui : CanvasLayer


func interact() -> void:
	crafting_ui.open_or_close()
