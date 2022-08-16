extends Node2D

var gameplay_music = preload("res://assets/sounds/gameplay_music.wav")
var menu_music = preload("res://assets/sounds/menu_music.wav")

var destroy_sound = preload("res://assets/sounds/destroy.wav")
var hit_sound = preload("res://assets/sounds/hit.wav")
var turn_sound = preload("res://assets/sounds/turn.wav")

var menu_mode = true
var game_was_started = false
var is_figure_falling = false
var is_hold_used = false
var drop_step_duration = 0.02
var clear_step_duration = 0.1
var step_duration
var quick_drop_mode = false
var gamefield

var full_lines = []

var lines_clear_total = 0
var level = 1
var score = 0

var next_figure = []
var hold_figure = []
var current_figure = []
var current_figure_rotation = 0 # 0 - default, 1 - 1 right rotation, 2 - 2, 3 - 3
var current_figure_position = {
	x = 0,
	y = 0
}

var rng

####################################################################################################
############################################ GAME LOGIC ############################################
####################################################################################################

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()

	for i in $Menu/menu_options.get_item_count():
		$Menu/menu_options.set_item_tooltip_enabled(i, false)

	gamefield = $Game/GameField/GameFieldCells
	step_duration = $Game/step_timer.wait_time
	init_menu()
	pick_next_figure()
	
func _process(delta):
	select_menu_item_on_hover()
		

func reset_game():
	score = 0
	level = 1
	lines_clear_total = 0
	gamefield.clear_field()

func start_game():
	close_menu()
	game_was_started = true
	$MusicPlayer.stream = gameplay_music
	$MusicPlayer.play()
	$Game.visible = true


func step():	
	if game_was_started && !menu_mode:		
		if !is_figure_falling:
			get_full_lines()
			
			if full_lines.size() > 0:
				clear_full_lines()
				play_sound(destroy_sound)		
			else:				
				quick_drop_mode = false
				$Game/step_timer.wait_time = step_duration
				
				current_figure = next_figure

				if spawn_current_figure_at_the_top():
					pick_next_figure()
					is_figure_falling = true
					is_hold_used = false 
				else:
					gameover()
		else:
			if !collision_check("down"):
				fix_figure()
				play_sound(hit_sound)
				var full_lines_count = get_full_lines()
				update_score_and_level(full_lines_count)

				if full_lines_count > 0:
					$Game/step_timer.stop()
					$Game/step_timer.wait_time = clear_step_duration
					$Game/step_timer.start()
				else:
					quick_drop_mode = false
					$Game/step_timer.wait_time = step_duration
			else:
				move_current_figure("down")

func gameover():
	game_was_started = false
	$Game.visible = false
	$Menu/menu_options.visible = false
	$Menu/bg_menu.visible = false
	$Menu/logo.visible = false
	$Menu.visible = true
	$Menu/bg_gameover.visible = true

func play_sound(sound):
	$SoundsPlayer.stream = sound
	$SoundsPlayer.play()

func get_full_lines():
	full_lines = []

	for i in gamefield.number_of_rows:
		var row_full = true

		for j in gamefield.number_of_cells_in_row:
			if gamefield.get_node('cell_' + str(i) + '_' + str(j)).cell_color_index == 0:
				row_full = false
				break

		if row_full:
			full_lines.push_back(i)

	return full_lines.size()

func clear_full_lines():
	var row = full_lines.pop_back()
	while row >= 0:
		for j in gamefield.number_of_cells_in_row:
			var cell = gamefield.get_node('cell_' + str(row) + '_' + str(j))
			var upper_cell = gamefield.get_node('cell_' + str(row-1) + '_' + str(j))
			var upper_cell_value = 0 
			
			if upper_cell != null: 
				upper_cell_value = upper_cell.cell_color_index

			cell.set_color_index(upper_cell_value)
		
		row -= 1
		

func spawn_current_figure_at_the_top():
	current_figure_rotation = 0
	current_figure_position.x = $Game/GameField/GameFieldCells.number_of_cells_in_row / 2 - 2
	current_figure_position.y = 0

	for i in current_figure.size():
		for j in current_figure[i].size():
			var cell = $Game/GameField/GameFieldCells.gamefield_map[i][current_figure_position.x + j]

			if cell.cell_color_index != 0:
				return false

			cell.set_color_index(current_figure[i][j])

	return true


func pick_next_figure():
	var figure_index = rng.randi() % 6 + 1

	# 1 - Red I     #FF0000
	# 2 - Blue O    #0000FF
	# 3 - Orange J  #FFAA00
	# 4 - Purple L  #FF00FF	
	# 5 - Green S   #00FF00
	# 6 - Brown T   #AA5600
	# 7 - Cyan Z    #00FFFF

	if figure_index == 1:
		next_figure = [
			[0, 0, 0, 0],
			[1, 1, 1, 1],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
		]		
	if figure_index == 2:
		next_figure = [
			[2, 2],
			[2, 2],
			
		]
		
	if figure_index == 3:
		next_figure = [
			[3, 3, 3],
			[0, 0, 3],
			[0, 0, 0],
		]
		
	if figure_index == 4:
		next_figure = [
			[4, 4, 4],
			[4, 0, 0],
			[0, 0, 0],
		]
		
	if figure_index == 5:
		next_figure = [
			[0, 5, 5],
			[5, 5, 0],
			[0, 0, 0],
		]
		
	if figure_index == 6:
		next_figure = [
			[6, 6, 6],
			[0, 6, 0],
			[0, 0, 0],
		]

	if figure_index == 7:
		next_figure = [
			[7, 7, 0],
			[0, 7, 7],
			[0, 0, 0],
		]

	$Game/UI/Next/next_figure.clear_field()
	$Game/UI/Next/next_figure.set_cells_colors(next_figure)

func move_current_figure(direction):
	clear_current_figure_position();	
	
	if direction == "down":
		current_figure_position.y += 1
	if direction == "left":
		current_figure_position.x -= 1
	if direction == "right":
		current_figure_position.x += 1

	draw_current_figure()


func clear_current_figure_position():
	for i in current_figure.size(): 
		for j in current_figure[i].size():
			var cur_y = current_figure_position.y + i
			var cur_x = current_figure_position.x + j
			var cell = gamefield.get_node("cell_" + str(cur_y) + "_" + str(cur_x))

			if cell && current_figure[i][j] != 0: 
				cell.set_color_index(0)


func draw_current_figure():
	for i in current_figure.size(): 
		for j in current_figure[i].size():
			var cur_y = current_figure_position.y + i
			var cur_x = current_figure_position.x + j
			var color = current_figure[i][j]

			if color != 0:
				gamefield.get_node("cell_" + str(cur_y) + "_" + str(cur_x)).set_color_index(color)


func collision_check(direction):
	var result = true

	clear_current_figure_position()

	for i in current_figure.size():
		for j in current_figure[i].size():
			if current_figure[i][j] != 0:
				var next_x = current_figure_position.x + j
				var next_y = current_figure_position.y + i

				if direction == "down":
					next_y += 1
				if direction == "left":
					next_x -= 1
				if direction == "right":
					next_x += 1

				var next_cell = gamefield.get_node("cell_" + str(next_y) + "_" + str(next_x))

				if !next_cell || next_cell.cell_color_index != 0:
					result = false
		
		if result == false:
			break

	draw_current_figure()			
	return result


func fix_figure():
	is_figure_falling = false
	current_figure_position = {x = 0, y = 0}
	current_figure = []


func _on_MusicPlayer_finished():
	$MusicPlayer.play(0)

func rotate_current_figure_left(draw = true):
	if draw:
		clear_current_figure_position()

	var n = current_figure.size();
	var old_figure = current_figure.duplicate(true)

	for i in (n / 2):
		var j = i

		while j < n - i - 1:
			var tmp            			 = current_figure[i][j];
			current_figure[i][j]         = current_figure[j][n-i-1];
			current_figure[j][n-i-1]     = current_figure[n-i-1][n-j-1];
			current_figure[n-i-1][n-j-1] = current_figure[n-j-1][i];
			current_figure[n-j-1][i]     = tmp;
			j += 1


	if rotate_collision_check(old_figure):
		current_figure_rotation -= 1

		if current_figure_rotation < 0:
			current_figure_rotation = 3

	if draw:
		draw_current_figure()

func rotate_collision_check(old_figure):	
	var out_of_bounds = true
	var old_restored = false

	while out_of_bounds && !old_restored:
		out_of_bounds = false
		var correction_direction = ""

		for i in current_figure.size():
			for j in current_figure[i].size():
				var cell = current_figure[i][j]
				if cell != 0:
					if current_figure_position.x + j >= gamefield.number_of_cells_in_row :
						out_of_bounds = true
						correction_direction = "left"
						break
					elif current_figure_position.x + j < 0:
						out_of_bounds = true
						correction_direction = "right"
						break
					elif current_figure_position.y + i >= gamefield.number_of_rows || current_figure_position.y + i < 0:
						current_figure = old_figure
						old_restored = true
					elif gamefield.get_node('cell_' + str(current_figure_position.y + i) + '_' + str(current_figure_position.x + j)).cell_color_index != 0:
						current_figure = old_figure
						old_restored = true
			
			if out_of_bounds || old_restored:
				break
		
		if out_of_bounds:
			if correction_direction == "left":
				current_figure_position.x -= 1
			elif correction_direction == "right":
				current_figure_position.x += 1

	return !old_restored


func rotate_current_figure_right():
	clear_current_figure_position()
	var n = current_figure.size();
	var old_figure = current_figure.duplicate(true)

	for k in 3:
		for i in (n / 2):
			var j = i

			while j < n - i - 1:
				var tmp            			 = current_figure[i][j];
				current_figure[i][j]         = current_figure[j][n-i-1];
				current_figure[j][n-i-1]     = current_figure[n-i-1][n-j-1];
				current_figure[n-i-1][n-j-1] = current_figure[n-j-1][i];
				current_figure[n-j-1][i]     = tmp;

				j += 1

	if rotate_collision_check(old_figure):
		current_figure_rotation += 1

		if current_figure_rotation >= 4:
			current_figure_rotation = 0

	draw_current_figure()

func update_score_and_level(lines_clear = 0):
	score += level^3 + (current_figure.size() - current_figure_position.y + 1) * 2 * level
	lines_clear_total += lines_clear
	
	if (lines_clear_total / 30) + 1 > level: 
		level = (lines_clear_total / 30) + 1
		step_duration /= 2
		$Game/step_timer.wait_time = step_duration 

	if lines_clear ==  1: 
		score += 100; 
	if lines_clear ==  2: 
		score += 400; 
	if lines_clear ==  3: 
		score += 900; 
	if lines_clear ==  4: 
		score += 2500; 

	update_text_info()

func update_text_info():
	var text = "Score:\t" + str(score) + "\n";
	text += "Lines:\t" + str(lines_clear_total) + "\n";
	text += "Level:\t" + str(level) + "\n";

	$Game/UI/text_info.text = text
							  
							  
	
		
	



####################################################################################################
########################################### INPUT LOGIC ############################################
####################################################################################################

func _unhandled_input(event):
	if !quick_drop_mode:
		if menu_mode && event.is_action_pressed("ui_cancel") && game_was_started:
			close_menu()
			$MusicPlayer.stream = gameplay_music
			$MusicPlayer.play()
		elif !menu_mode && event.is_action_pressed("ui_cancel"):
			init_menu()
		elif !menu_mode && !is_hold_used && event.is_action_pressed("hold"):
			var is_first_hold = !hold_figure
			is_hold_used = true
			clear_current_figure_position()

			while current_figure_rotation != 0:
				rotate_current_figure_left(false)

			if !is_first_hold:
				var temp_hold_figure = hold_figure.duplicate(true)
				hold_figure = current_figure.duplicate(true)
				next_figure = temp_hold_figure.duplicate(true)
			else:
				hold_figure = current_figure.duplicate(true)

			$Game/UI/Hold/hold_figure.set_cells_colors(hold_figure)
			current_figure = next_figure.duplicate(true)

			spawn_current_figure_at_the_top()
			is_figure_falling = true

			if is_first_hold:
				pick_next_figure()
			
		if game_was_started && is_figure_falling:
			if event.is_action_pressed("rotate_left"):
				rotate_current_figure_left()
				play_sound(turn_sound)
			if event.is_action_pressed("rotate_right"):
				rotate_current_figure_right()
				play_sound(turn_sound)
			if event.is_action_pressed("drop"):
				quick_drop_mode = true
				$Game/step_timer.stop()
				$Game/step_timer.wait_time = drop_step_duration
				$Game/step_timer.start()
				step()

		process_repeatable_actions()


func _on_input_timer_timeout():
	if !quick_drop_mode:
		process_repeatable_actions()

func process_repeatable_actions():
	if game_was_started && is_figure_falling:
		$input_timer.start()

		if Input.is_action_pressed("move_left"):
			if collision_check("left"):
				move_current_figure("left")
		elif Input.is_action_pressed("move_right"):
			if collision_check("right"):
				move_current_figure("right")
		elif Input.is_action_pressed("move_down"):
			if collision_check("down"):
				restart_step_timer()
				move_current_figure("down")


func restart_step_timer():
	$Game/step_timer.stop()
	$Game/step_timer.start(0)

####################################################################################################
############################################ MENU LOGIC ############################################
####################################################################################################

func select_menu_item_on_hover():
	if menu_mode:
		var menu_options = $Menu/menu_options
		var mouse_position = get_viewport().get_mouse_position()
		mouse_position.y -= menu_options.get_position().y

		var index = menu_options.get_item_at_position(mouse_position, true)
		
		if index != -1:
			menu_options.select(index)

func activate_menu_item_on_mouse_position():
	var menu_options = $Menu/menu_options
	var mouse_position = get_viewport().get_mouse_position()
	mouse_position.y -= menu_options.get_position().y

	var index = menu_options.get_item_at_position(mouse_position, true)
	
	if index != -1:
		_on_menu_options_item_activated(index)
			
func _on_menu_options_item_activated(index:int):
	print("Selected: " + $Menu/menu_options.get_item_text(index))
	var itemText = $Menu/menu_options.get_item_text(index)
	
	if itemText == "Start game" || itemText == "Resume game":
		if !game_was_started:
			reset_game()

		start_game()
	elif itemText == "Settings":
		pass
	elif itemText == "Exit":
		get_tree().quit()
		

func init_menu():
	menu_mode = true

	$Game.visible = false
	$Menu/menu_options.visible = true
	$Menu/bg_menu.visible = true
	$Menu/logo.visible = true
	$Menu.visible = true
	$Menu/bg_gameover.visible = false

	$MusicPlayer.stream = menu_music
	$MusicPlayer.play()
	$Menu/menu_options.select(0)
	$Menu/menu_options.grab_focus()
	$Game/step_timer.stop()

	if game_was_started:
		$Menu/menu_options.set_item_text(0, "Resume game")
	else: 
		$Menu/menu_options.set_item_text(0, "Start game")


func close_menu():
	$Menu.visible = false
	menu_mode = false
	$Game/step_timer.start()
		

func _on_menu_options_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == 1:
				activate_menu_item_on_mouse_position()
