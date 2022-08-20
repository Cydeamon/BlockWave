extends Control

signal exit
signal settings
signal start_game

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
