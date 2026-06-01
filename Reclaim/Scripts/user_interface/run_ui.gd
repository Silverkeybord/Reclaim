extends Control

const RUN_TIME_TEXT := "Run time :  "

@export var wave_time_label : Label

func _process(_delta: float) -> void:
	wave_time_label.text = RUN_TIME_TEXT + str(int(round(Global.sector_run_time)))
