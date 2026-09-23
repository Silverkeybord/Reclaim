extends StaticBody3D

@export var authorisation_ui : CouncilAuthorisation


func interact() -> void:
	authorisation_ui.open_ui()
