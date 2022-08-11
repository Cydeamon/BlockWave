extends Node2D

var gameplay_music = preload("res://assets/sounds/gameplay_music.wav")
var menu_music = preload("res://assets/sounds/menu_music.wav")
var menu_mode = true
var game_was_started = false
var is_figure_falling = false
var current_figure_cells = []

func _ready():
	init_menu()
	pick_next_figure()

func _on_menu_options_item_activated(index:int):
	print("Selected: " + $Menu/menu_options.get_item_text(index))
	var itemText = $Menu/menu_options.get_item_text(index)
	
	if itemText == "Start game":
		start_game()
	elif itemText == "Settings":
		pass
	elif itemText == "Exit":
		get_tree().quit()


func init_menu():
	menu_mode = true
	$Menu.visible = true
	$MusicPlayer.stream = menu_music
	$MusicPlayer.play()
	$Menu/menu_options.select(0)
	$Menu/menu_options.grab_focus()
	$Game.visible = false
	$Game/step_timer.stop()


func start_game():
	close_menu()
	game_was_started = true
	$MusicPlayer.stream = gameplay_music
	$MusicPlayer.play()
	$Game.visible = true


func close_menu():
	$Menu.visible = false
	menu_mode = false
	$Game/step_timer.start()
	
func _unhandled_input(event):
	if menu_mode && event.is_action_pressed("ui_cancel") && game_was_started:
		close_menu()
		$MusicPlayer.stream = gameplay_music
		$MusicPlayer.play()
	elif !menu_mode && event.is_action_pressed("ui_cancel"):
		init_menu()

		
func _on_MusicPlayer_finished():
	$MusicPlayer.play(0)


func step():
	if !is_figure_falling:
		spawn_next_figure()
		pick_next_figure()
		is_figure_falling = true
	else:		
		if !collision_check("down"):
			fix_figure()
		else:
			move_current_figure_down()


func spawn_next_figure():
	var draw_x = $Game/GameField/GameFieldCells.number_of_cells_in_row / 2 - 2

	for i in 2:
		for j in 4:
			var cell = $Game/GameField/GameFieldCells.gamefield_map[i][draw_x + j]
			cell.set_color_index($Game/UI/Next/next_figure.gamefield_map[i][j].cell_color_index)
			current_figure_cells.push_front(cell)



func pick_next_figure():
	var figure_index = randi() % 6 + 1
	var figure = []

	# 1 - Red I     #FF0000
	# 2 - Blue O    #0000FF
	# 3 - Orange J  #FFAA00
	# 4 - Purple L  #FF00FF	
	# 5 - Green S   #00FF00
	# 6 - Brown T   #AA5600
	# 7 - Cyan Z    #00FFFF

	if figure_index == 1:
		figure = [
			[0, 0, 0, 0],
			[1, 1, 1, 1],
		]		
	if figure_index == 2:
		figure = [
			[0, 2, 2, 0],
			[0, 2, 2, 0],
		]
		
	if figure_index == 3:
		figure = [
			[3, 3, 3, 0],
			[0, 0, 3, 0],
		]
		
	if figure_index == 4:
		figure = [
			[4, 4, 4, 0],
			[4, 0, 0, 0],
		]
		
	if figure_index == 5:
		figure = [
			[0, 5, 5, 0],
			[5, 5, 0, 0],
		]
		
	if figure_index == 6:
		figure = [
			[6, 6, 6, 0],
			[0, 6, 0, 0],
		]

	if figure_index == 7:
		figure = [
			[7, 7, 0, 0],
			[0, 7, 7, 0],
		]

	for i in 2:
		for j in 4:
			$Game/UI/Next/next_figure.gamefield_map[i][j].set_color_index(figure[i][j])

	

func move_current_figure_down():
	var gamefield = $Game/GameField/GameFieldCells

	for i in current_figure_cells.size(): 
		var cell = current_figure_cells[i]

		if cell.cell_color_index > 0:
			var next_cell = gamefield.get_node("cell_" + str(cell.y + 1) + "_" + str(cell.x))
			next_cell.set_color_index(cell.cell_color_index)
			cell.set_color_index(0)
			current_figure_cells[i] = next_cell


func collision_check(direction):
	var gamefield = $Game/GameField/GameFieldCells

	for i in current_figure_cells.size(): 
		var cell = current_figure_cells[i]

		if cell.cell_color_index > 0:
			var next_cell

			if direction == "down":
				next_cell = gamefield.get_node("cell_" + str(cell.y + 1) + "_" + str(cell.x))
			if direction == "left":
				next_cell = gamefield.get_node("cell_" + str(cell.y) + "_" + str(cell.x-1))
			if direction == "right":
				next_cell = gamefield.get_node("cell_" + str(cell.y) + "_" + str(cell.x+1))			
	
			if !next_cell:
				return false
			
			if next_cell.cell_color_index != 0:
				var is_self_collide = false

				for temp_cell in current_figure_cells: 
					if temp_cell == next_cell:
						is_self_collide = true
						break

				if !is_self_collide:
					return false

	return true


func fix_figure():
	is_figure_falling = false
	current_figure_cells = []
