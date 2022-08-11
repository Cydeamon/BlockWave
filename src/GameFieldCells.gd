extends Node2D

export var number_of_rows: int
export var number_of_cells_in_row: int
export var limit_rows_draw: int

var gamefield_map = []
var res_cell = preload("res://assets/Cell.tscn")

func _ready():
	create_cells()
	
func clear_field():
	for i in gamefield_map.size():
		for j in gamefield_map[i].size():
			gamefield_map[i][j].set_color_index(0)

func create_cells():
	var cell_width = 50
	var cell_height = 50

	for i in number_of_rows:
		var gamefield_map_row = []

		for j in number_of_cells_in_row:
			var offset_x = j * cell_width
			var offset_y = i * cell_height
			var cell = res_cell.instance()
			
			add_child(cell)
			cell.name = "cell_" + str(i) + "_" + str(j)
			cell.position.x = offset_x
			cell.position.y = offset_y
			cell.x = j
			cell.y = i

			gamefield_map_row.push_back(cell)

			if i >= limit_rows_draw:
				cell.visible = false
		
		gamefield_map.push_back(gamefield_map_row)


func update_cells():
	for i in number_of_rows:
		for j in number_of_cells_in_row:
			gamefield_map[i][j].update_cell_color()
						