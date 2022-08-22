extends Control

signal exit
signal start_game
signal value_changed

var active_menu_tree = []
var active_menu = null;

var controller_buttons_icons = {
	joy_btn_0 = preload("res://assets/inputs/joy-button-a.png"),
	joy_btn_1 = preload("res://assets/inputs/joy-button-b.png"),
	joy_btn_2 = preload("res://assets/inputs/joy-button-x.png"),
	joy_btn_3 = preload("res://assets/inputs/joy-button-y.png"),
	joy_btn_4 = preload("res://assets/inputs/joy-button-lb.png"),
	joy_btn_5 = preload("res://assets/inputs/joy-button-rb.png"),
	joy_btn_6 = preload("res://assets/inputs/joy-button-lt.png"),
	joy_btn_7 = preload("res://assets/inputs/joy-button-rt.png"),
	joy_btn_8 = preload("res://assets/inputs/joy-button-l.png"),
	joy_btn_9 = preload("res://assets/inputs/joy-button-r.png"),
	joy_btn_12 = preload("res://assets/inputs/joy-button-dpad-left.png"),
	joy_btn_13 = preload("res://assets/inputs/joy-button-dpad-right.png"),
	joy_btn_14 = preload("res://assets/inputs/joy-button-dpad-up.png"),
	joy_btn_15 = preload("res://assets/inputs/joy-button-dpad-down.png")
}

func _ready():
	$MainMenu.show()
	active_menu = $MainMenu
	activate_first()

func update_key_binds_ui(keybinds):
	for action in keybinds.keys():
		var action_node = $ControlsMenu/Inputs.get_node(action)

		# Keyboard button
		action_node.get_node("keyboard").text = OS.get_scancode_string(int(keybinds[action]['key_codes'][0]))

		if action_node.get_node("keyboard").text == "Left":
			action_node.get_node("keyboard").text = "←"
		elif action_node.get_node("keyboard").text == "Right":
			action_node.get_node("keyboard").text = "→"
		elif action_node.get_node("keyboard").text == "Up":
			action_node.get_node("keyboard").text = "↑"
		elif action_node.get_node("keyboard").text == "Down":
			action_node.get_node("keyboard").text = "↓"

		# Controller button
		action_node.get_node("joy_button").icon = controller_buttons_icons["joy_btn_" + keybinds[action]['joy_buttons'][0]]
		
func _on_Exit_pressed():
	emit_signal("exit")


func _on_Settings_pressed():
	active_menu_tree.push_front(active_menu)
	active_menu = $SettingsMenu
	activate_first()
	$MainMenu.hide()
	$SettingsMenu.show()

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


func _on_Controls_pressed():
	active_menu_tree.push_front(active_menu)
	active_menu.hide()
	active_menu = $ControlsMenu
	$ControlsMenu.show()
	activate_first()
