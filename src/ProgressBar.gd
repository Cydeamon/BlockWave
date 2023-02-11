extends Control

signal value_changed

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
	check_value()
	recalc()
	emit_signal("value_changed", self, value)

func increase():
	set_value(value + increase_decrease_step)
	
func decrease():
	set_value(value - increase_decrease_step)
	
func check_value():
	if value > max_value:
		value = max_value
	if value < min_value:
		value = min_value

func recalc():
	var width = $Node2D/Light2D.texture.get_width()
	var max_value_normalized = max_value - min_value
	var value_normalized = value - min_value
	var percentage = (value_normalized / max_value_normalized) * 100

	$Node2D/Light2D/filled.rect_size.x = width * percentage / 100
	$Node2D/Light2D/not_filled.rect_size.x = width * (100 - percentage) / 100
	$Node2D/Light2D/not_filled.rect_position.x = $Node2D/Light2D/filled.rect_position.x + $Node2D/Light2D/filled.rect_size.x


func set_value_percent(percentage):
	var max_value_normalized = max_value - min_value
	var val = (max_value_normalized * percentage / 100) + min_value
	set_value(val)

func _on_click_trigger_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		# Set progerss bar value with mouse click
		if event.pressed && event.button_index == 1:
			var width = $click_trigger.rect_size.x
			var position = $click_trigger.rect_global_position.x
			var click_x = event.global_position.x
			var percentage = ((click_x - position) / width) * 100
			set_value_percent(percentage) 
