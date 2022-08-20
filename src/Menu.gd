extends Control

signal exit
signal settings
signal start_game
signal value_changed

var active_menu_tree = []
var active_menu = null;

func _ready():
	$MainMenu.show()
	active_menu = $MainMenu
	activate_first()

func _on_Exit_pressed():
	emit_signal("exit")


func _on_Settings_pressed():
	active_menu_tree.push_front(active_menu)
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
	var checkbox = focused_menu_option.get_node("CheckBox")
	
	if progressBar:
		if event.is_action_pressed("ui_right"):
			progressBar.increase()
			emit_signal("value_changed", focused_menu_option, progressBar.value)
		if event.is_action_pressed("ui_left"):
			progressBar.decrease()
			emit_signal("value_changed", focused_menu_option, progressBar.value)
	elif checkbox:
		if event.is_action_pressed("ui_accept"):
			checkbox.pressed = !checkbox.pressed
			emit_signal("value_changed", focused_menu_option, checkbox.pressed)


func _on_Back_pressed():
	if active_menu_tree.size() == 0:
		return false

	active_menu.hide()
	active_menu = active_menu_tree.pop_front()
	active_menu.show()
	return true


func _on_CheckBox_toggled(button_pressed:bool):	
	emit_signal("value_changed", active_menu.get_focus_owner().get_parent(), button_pressed)

