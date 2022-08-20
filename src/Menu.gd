extends Control

signal exit
signal settings
signal start_game
signal value_changed

var active_menu = null;

func _ready():
	$MainMenu.show()
	active_menu = $MainMenu
	activate_first()

func _on_Exit_pressed():
	emit_signal("exit")


func _on_Settings_pressed():
	active_menu = $SettingsMenu
	activate_first()
	$MainMenu.hide()
	$SettingsMenu.show()
	emit_signal("settings")

func _on_StartGame_pressed():
	emit_signal("start_game")

func activate_first():
	active_menu.get_children()[0].grab_focus()



func _on_menu_option_gui_input(event:InputEvent):
	var focused_menu_option = active_menu.get_focus_owner()
	var progressBar = focused_menu_option.get_node("ProgressBar")
	
	if progressBar:
		if event.is_action_pressed("ui_right"):
			progressBar.increase()
			emit_signal("value_changed", focused_menu_option, progressBar.value)
		if event.is_action_pressed("ui_left"):
			progressBar.decrease()
			emit_signal("value_changed", focused_menu_option, progressBar.value)