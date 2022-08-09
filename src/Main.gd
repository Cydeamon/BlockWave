extends Node2D

var gameplay_music = preload("res://assets/sounds/gameplay_music.wav")

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
	$Menu.visible = true
	$Menu/menu_options.select(0)
	$Menu/menu_options.grab_focus()


func start_game():
	$Menu.visible = false
	$MusicPlayer.stream = gameplay_music
	$MusicPlayer.play()