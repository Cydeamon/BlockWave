extends Control

export var min_value : float
export var max_value : float
export var value : float
export var increase_decrease_step: float

func _ready():
	recalc()

func set_min_value(val):
	min_value = val
	recalc()

func set_max_value(val):
	max_value = val
	recalc()

func set_value(val):
	value = val
	recalc()

func increase():
	value += increase_decrease_step
	check_value()
	recalc()
	
func decrease():
	value -= increase_decrease_step
	check_value()
	recalc()
	
func check_value():
	if value > max_value:
		value = max_value
	if value < min_value:
		value = min_value

func recalc():
	var width = $Node2D/Light2D.texture.get_width() - 250
	var max_value_normalized = max_value - min_value
	var value_normalized = value - min_value
	var percentage = (value_normalized / max_value_normalized) * 100

	$Node2D/Light2D/filled.rect_size.x = width * percentage / 100
	$Node2D/Light2D/not_filled.rect_size.x = width * (100 - percentage) / 100
	$Node2D/Light2D/not_filled.rect_position.x = $Node2D/Light2D/filled.rect_position.x + $Node2D/Light2D/filled.rect_size.x

