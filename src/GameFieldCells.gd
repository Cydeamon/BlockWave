extends Node2D

export var number_of_rows: int
export var number_of_cells_in_row: int

var res_cell = preload("res://assets/Cell.tscn")

func _ready():
	create_cells()	

func create_cells():
	var cell_width = 50
	var cell_height = 50

	for i in number_of_rows:
		for j in number_of_cells_in_row:
			var offset_x = j * cell_width
			var offset_y = i * cell_height
			var cell = res_cell.instance()

			cell.name = "cell_" + str(i) + "_" + str(j)
			cell.position.x = offset_x
			cell.position.y = offset_y

			add_child(cell)
						