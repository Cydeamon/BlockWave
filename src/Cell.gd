extends Node2D

var cell_color_index = 0

func _ready():
	update_cell_color()

func set_color_index(index):
	if index > 7 || index < 0:
		index = 0

	cell_color_index = index
	update_cell_color()


func update_cell_color():
	# 0 - Empty
	# 1 - Red I     #FF0000
	# 2 - Blue O    #0000FF
	# 3 - Orange J  #FFAA00
	# 4 - Purple L  #FF00FF	
	# 5 - Green S   #00FF00
	# 6 - Brown T   #AA5600
	# 7 - Cyan Z    #00FFFF

	if cell_color_index == 0:
		$cell_color.color = Color(0, 0, 0, 1)
		
	if cell_color_index == 1:
		$cell_color.color = Color(1, 0, 0, 1)
		
	if cell_color_index == 2:
		$cell_color.color = Color(0, 0, 1, 1)
		
	if cell_color_index == 3:
		$cell_color.color = Color(1, 0.66, 0, 1)
		
	if cell_color_index == 4:
		$cell_color.color = Color(1, 0, 1, 1)
		
	if cell_color_index == 5:
		$cell_color.color = Color(0, 1, 0, 1)
		
	if cell_color_index == 6:
		$cell_color.color = Color(0.66, 0.32, 0, 1)

	if cell_color_index == 7:
		$cell_color.color = Color(0, 1, 1, 1)

