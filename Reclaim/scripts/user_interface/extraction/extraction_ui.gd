extends CanvasLayer

const FIRST_COLOR := Color(0.768, 0.968, 0.947, 1.0)
const SECOND_COLOR := Color(0.149, 0.892, 0.869, 1.0)
const THIRD_COLOR := Color(0.425, 0.865, 0.747, 1.0)
const FOURTH_COLOR := Color(0.776, 0.776, 0.0, 1.0)
const FITH_COLOR := Color(1.0, 0.271, 0.0, 1.0)

const FITHS_RATIO_DIVISOR := 0.2

# each number is multiplyed by 0.2 for the ratio. using intergets for better precision
const EXTRACTION_BAR_COLOR_RATIOS := {
	1 : FIRST_COLOR,
	2 : SECOND_COLOR,
	3 : THIRD_COLOR,
	4 : FOURTH_COLOR,
	5 : FITH_COLOR
}

@export var extraction_bar : ProgressBar
@export var total_label : Label
@export var weight_label : Label
@export var sector_hflow : HFlowContainer
@export var extraction_hflow : HFlowContainer

var current_weight : float
var max_weight : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	open_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if current_weight > 0:
		var extraction_weight_ratio = extraction_bar.value / extraction_bar.max_value
		var color_key = int(ceil(extraction_weight_ratio / FITHS_RATIO_DIVISOR))
		
		extraction_bar.modulate = EXTRACTION_BAR_COLOR_RATIOS[color_key]


func open_ui() -> void:
	current_weight = 0
	max_weight = 100
	
	extraction_bar.max_value = max_weight
	extraction_bar.value = current_weight
	
	set_process(true)
