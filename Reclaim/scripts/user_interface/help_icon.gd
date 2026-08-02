extends Control

@export var help_display : Control


func _on_mouse_entered() -> void:
	help_display.visible = true


func _on_mouse_exited() -> void:
	help_display.visible = false
