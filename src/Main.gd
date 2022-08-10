extends Node2D

var gameplay_music = preload("res://assets/sounds/gameplay_music.wav")
var menu_music = preload("res://assets/sounds/menu_music.wav")
var menu_mode = true
var game_was_started = false

func _ready():
	init_menu()

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


func start_game():
	close_menu()
	game_was_started = true
	$MusicPlayer.stream = gameplay_music
	$MusicPlayer.play()
	$Game.visible = true


func close_menu():
	$Menu.visible = false
	menu_mode = false
	
func _unhandled_input(event):
	if menu_mode && event.is_action_pressed("ui_cancel") && game_was_started:
		close_menu()
		$MusicPlayer.stream = gameplay_music
		$MusicPlayer.play()
	elif !menu_mode && event.is_action_pressed("ui_cancel"):
		init_menu()

		
func _on_MusicPlayer_finished():
	$MusicPlayer.play(0)
